module Orders
  class Cancel
    def initialize(order)
      @order = order
    end

    def call
      cancelled = ActiveRecord::Base.transaction do
        changed = Order.where(id: @order.id, status: "pending")
                       .update_all(status: "cancelled", updated_at: Time.current)

        restock! if changed.positive?
        changed.positive?
      end

      return failure(:not_cancellable) unless cancelled

      OrderMailer.cancellation(@order).deliver_later

      Result.success(@order.reload)
    end

    private

    def restock!
      @order.line_items.order(:product_id).each do |item|
        Product.where(id: item.product_id).update_all([ "stock = stock + ?", item.quantity ])
      end
    end

    def failure(error)
      Result.failure(error, I18n.t(error, scope: "orders.cancel.errors"), @order)
    end
  end
end
