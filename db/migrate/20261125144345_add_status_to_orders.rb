class AddStatusToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :status, :string, null: false, default: "pending"
    add_check_constraint :orders, "status IN ('pending', 'cancelled')", name: "orders_status_allowed"
  end
end
