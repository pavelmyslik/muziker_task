FactoryBot.define do
  factory :order do
    customer_name { "Jan Novak" }
    email { "jan@example.com" }
    phone { "+420 777 123 456" }
    street { "Hlavni 12" }
    city { "Praha" }
    postal_code { "110 00" }
    country { "CZ" }
    total { "0.00" }
    idempotency_key { SecureRandom.uuid }
  end
end
