class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock, null: false, default: 0

      t.timestamps
    end

    add_index :products, "lower(name)", unique: true, name: "index_products_on_lower_name"
    add_check_constraint :products, "price >= 0", name: "products_price_non_negative"
    add_check_constraint :products, "stock >= 0", name: "products_stock_non_negative"
  end
end
