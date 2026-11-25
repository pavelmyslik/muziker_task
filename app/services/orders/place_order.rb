module Orders
  class PlaceOrder
    class OutOfStock < StandardError
      attr_reader :product

      def initialize(product)
        @product = product
        super("Not enough stock for product #{product.id}")
      end
    end

    def initialize(customer:, items:, idempotency_key:)
      @customer = customer
      @items = items
      @idempotency_key = idempotency_key
    end

    def call
      existing_order = Order.find_by(idempotency_key: @idempotency_key)
      return success(existing_order) if existing_order

      quantities = normalized_quantities
      return failure(:invalid_quantity) if quantities.nil?
      return failure(:empty_order) if quantities.empty?

      products = Product.where(id: quantities.keys).index_by(&:id)
      return failure(:product_not_found) if products.size != quantities.size

      order = build_order(quantities, products)
      return failure(:invalid_order, order) unless order.valid?

      ActiveRecord::Base.transaction do
        quantities.keys.sort.each { |product_id| decrement_stock!(products.fetch(product_id), quantities.fetch(product_id)) }
        order.save!
      end

      OrderMailer.confirmation(order).deliver_later

      success(order)
    rescue OutOfStock => e
      failure(:out_of_stock, order, product: e.product.name)
    rescue ActiveRecord::RecordNotUnique
      success(Order.find_by!(idempotency_key: @idempotency_key))
    end

    private

    def normalized_quantities
      quantities = Hash.new(0)

      @items.each do |item|
        quantity = Integer(item[:quantity].to_s.presence || "0", 10, exception: false)
        return nil if quantity.nil? || quantity.negative?

        quantities[Integer(item[:product_id].to_s, 10, exception: false)] += quantity
      end

      quantities.reject { |_product_id, quantity| quantity.zero? }
    end

    def build_order(quantities, products)
      order = Order.new(**@customer, idempotency_key: @idempotency_key)

      quantities.each do |product_id, quantity|
        product = products.fetch(product_id)
        order.line_items.build(product:, quantity:, unit_price: product.price)
      end

      order.total = order.line_items.sum(&:subtotal)
      order
    end

    def decrement_stock!(product, quantity)
      updated_rows = Product.where(id: product.id)
                            .where("stock >= ?", quantity)
                            .update_all([ "stock = stock - ?", quantity ])

      raise OutOfStock, product if updated_rows.zero?
    end

    def success(order) = Result.success(order)

    def failure(error, order = nil, **interpolations)
      Result.failure(error, I18n.t(error, scope: "orders.place_order.errors", **interpolations), order)
    end
  end
end
