# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_25_135638) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "product_id"], name: "index_line_items_on_order_id_and_product_id", unique: true
    t.index ["product_id"], name: "index_line_items_on_product_id"
    t.check_constraint "quantity > 0", name: "line_items_quantity_positive"
    t.check_constraint "unit_price >= 0::numeric", name: "line_items_unit_price_non_negative"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer_name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "street", null: false
    t.string "city", null: false
    t.string "postal_code", null: false
    t.string "country", limit: 2, null: false
    t.decimal "total", precision: 10, scale: 2, null: false
    t.string "token", null: false
    t.string "idempotency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["idempotency_key"], name: "index_orders_on_idempotency_key", unique: true
    t.index ["token"], name: "index_orders_on_token", unique: true
    t.check_constraint "total >= 0::numeric", name: "orders_total_non_negative"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_products_on_lower_name", unique: true
    t.check_constraint "price >= 0::numeric", name: "products_price_non_negative"
    t.check_constraint "stock >= 0", name: "products_stock_non_negative"
  end

  add_foreign_key "line_items", "orders"
  add_foreign_key "line_items", "products"
end
