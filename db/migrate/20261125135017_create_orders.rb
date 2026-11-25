class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :customer_name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :street, null: false
      t.string :city, null: false
      t.string :postal_code, null: false
      t.string :country, null: false, limit: 2
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :token, null: false
      t.string :idempotency_key, null: false

      t.timestamps
    end

    add_index :orders, :token, unique: true
    add_index :orders, :idempotency_key, unique: true
    add_check_constraint :orders, "total >= 0", name: "orders_total_non_negative"
  end
end
