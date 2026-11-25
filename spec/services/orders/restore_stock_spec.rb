require "rails_helper"

RSpec.describe Orders::RestoreStock do
  it "adds the quantity of every line item back to the product stock" do
    guitar = create(:product, stock: 1)
    strings = create(:product, stock: 0)
    order = create(:order)
    create(:line_item, order:, product: guitar, quantity: 2)
    create(:line_item, order:, product: strings, quantity: 5)

    described_class.new(order).call

    expect(guitar.reload.stock).to eq(3)
    expect(strings.reload.stock).to eq(5)
  end
end
