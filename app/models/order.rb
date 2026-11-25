class Order < ApplicationRecord
  has_secure_token :token

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :country, with: ->(country) { country.strip.upcase }

  validates :customer_name, :phone, :street, :city, :postal_code, :idempotency_key, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :country, length: { is: 2 }
  validates :total, numericality: { greater_than_or_equal_to: 0 }
end
