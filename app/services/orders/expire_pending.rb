module Orders
  class ExpirePending
    def call
      cutoff = older_than.ago

      Order.pending.where(created_at: ...cutoff).find_each.count do |order|
        expire(order)
      end
    end

    private

    def expire(order)
      ActiveRecord::Base.transaction do
        changed = Order.where(id: order.id, status: "pending")
                       .update_all(status: "expired", updated_at: Time.current)

        RestoreStock.new(order).call if changed.positive?
        changed.positive?
      end
    end

    def older_than = Rails.configuration.x.orders.pending_expiration
  end
end
