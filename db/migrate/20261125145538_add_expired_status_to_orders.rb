class AddExpiredStatusToOrders < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :orders, "status IN ('pending', 'cancelled')", name: "orders_status_allowed"
    add_check_constraint :orders, "status IN ('pending', 'cancelled', 'expired')", name: "orders_status_allowed"

    # Job hledá pending objednávky podle stáří; částečný index pokrývá jen je.
    add_index :orders, :created_at, where: "status = 'pending'", name: "index_orders_on_created_at_pending"
  end
end
