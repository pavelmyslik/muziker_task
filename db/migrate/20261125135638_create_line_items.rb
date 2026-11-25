class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items do |t|
      t.references :order, null: false, foreign_key: true, index: false
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :line_items, [ :order_id, :product_id ], unique: true
    add_check_constraint :line_items, "quantity > 0", name: "line_items_quantity_positive"
    add_check_constraint :line_items, "unit_price >= 0", name: "line_items_unit_price_non_negative"
  end
end
