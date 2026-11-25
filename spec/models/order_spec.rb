require "rails_helper"

RSpec.describe Order do
  it "is valid with default factory attributes" do
    expect(build(:order)).to be_valid
  end

  it "generates a token on create" do
    expect(create(:order).token).to be_present
  end

  it "normalizes email to stripped lowercase" do
    expect(build(:order, email: "  Jan@Example.COM ").email).to eq("jan@example.com")
  end

  it "normalizes country to uppercase" do
    expect(build(:order, country: "cz").country).to eq("CZ")
  end

  it "rejects an invalid email" do
    order = build(:order, email: "not-an-email")

    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present
  end

  it "rejects a country code that is not 2 characters long" do
    order = build(:order, country: "CZE")

    expect(order).not_to be_valid
    expect(order.errors[:country]).to be_present
  end

  it "requires a phone" do
    order = build(:order, phone: nil)

    expect(order).not_to be_valid
    expect(order.errors[:phone]).to be_present
  end

  it "allows a zero total" do
    expect(build(:order, total: 0)).to be_valid
  end

  it "rejects a negative total" do
    order = build(:order, total: -1)

    expect(order).not_to be_valid
    expect(order.errors[:total]).to be_present
  end

  it "has idempotency_key uniqueness enforced by the database" do
    existing = create(:order)
    duplicate = build(:order, idempotency_key: existing.idempotency_key)

    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "destroys its line items when destroyed" do
    order = create(:line_item).order

    expect { order.destroy }.to change(LineItem, :count).by(-1)
  end
end
