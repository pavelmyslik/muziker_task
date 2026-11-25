class Order < ApplicationRecord
  PHONE_FORMAT = /\A(?:\+|00)?\d{9,15}\z/
  POSTAL_CODE_FORMAT = /\A\d{5}\z/ # CZ + SK

  has_secure_token :token

  has_many :line_items, dependent: :destroy

  enum :status, { pending: "pending", cancelled: "cancelled" }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :country, with: ->(country) { country.strip.upcase }
  normalizes :phone, with: ->(phone) { phone.gsub(/\s+/, "") }
  normalizes :postal_code, with: ->(postal_code) { postal_code.gsub(/\s+/, "") }

  validates :customer_name, :phone, :street, :city, :postal_code, :idempotency_key, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: PHONE_FORMAT }, allow_blank: true
  validates :postal_code, format: { with: POSTAL_CODE_FORMAT }, allow_blank: true
  validates :country, length: { is: 2 }
  validates :total, numericality: { greater_than_or_equal_to: 0 }
end
