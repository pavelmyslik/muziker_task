require "rails_helper"

RSpec.describe LineItem do
  it "calculates subtotal as unit price times quantity" do
    line_item = build(:line_item, unit_price: "19.90", quantity: 3)

    expect(line_item.subtotal).to eq(BigDecimal("59.70"))
  end

  it "rejects zero quantity" do
    line_item = build(:line_item, quantity: 0)

    expect(line_item).not_to be_valid
    expect(line_item.errors[:quantity]).to be_present
  end

  it "has the same product only once per order enforced by the database" do
    existing = create(:line_item)
    duplicate = build(:line_item, order: existing.order, product: existing.product)

    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "keeps its unit price when the product price changes later" do
    line_item = create(:line_item, product: create(:product, price: "100.00"))

    line_item.product.update!(price: "150.00")

    expect(line_item.reload.unit_price).to eq(BigDecimal("100.00"))
  end
end
