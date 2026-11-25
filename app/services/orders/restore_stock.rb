module Orders
  class RestoreStock
    def initialize(order)
      @order = order
    end

    def call
      @order.line_items.order(:product_id).each do |item|
        Product.where(id: item.product_id).update_all([ "stock = stock + ?", item.quantity ])
      end
    end
  end
end
