FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { "100.00" }
    stock { 10 }
  end
end
