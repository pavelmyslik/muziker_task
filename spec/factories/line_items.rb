FactoryBot.define do
  factory :line_item do
    order
    product
    quantity { 1 }
    unit_price { product.price }
  end
end
