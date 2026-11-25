require "rails_helper"

RSpec.describe Orders::ExpirePending do
  let(:product) { create(:product, stock: 3) }

  def order_with_item(created_at:, status: "pending")
    create(:order, created_at:, status:).tap do |order|
      create(:line_item, order:, product:, quantity: 2)
    end
  end

  it "expires pending orders older than the expiration period and restores their stock" do
    order = order_with_item(created_at: 15.days.ago)

    expect(described_class.new.call).to eq(1)

    expect(order.reload).to be_expired
    expect(product.reload.stock).to eq(5)
  end

  it "keeps recent pending orders untouched" do
    order = order_with_item(created_at: 13.days.ago)

    expect(described_class.new.call).to eq(0)

    expect(order.reload).to be_pending
    expect(product.reload.stock).to eq(3)
  end

  it "ignores old cancelled orders and does not restore their stock again" do
    order = order_with_item(created_at: 15.days.ago, status: "cancelled")

    described_class.new.call

    expect(order.reload).to be_cancelled
    expect(product.reload.stock).to eq(3)
  end

  it "does nothing when run again" do
    order_with_item(created_at: 15.days.ago)
    described_class.new.call

    expect(described_class.new.call).to eq(0)
    expect(product.reload.stock).to eq(5)
  end

  it "uses the configured expiration period by default" do
    expect(Rails.configuration.x.orders.pending_expiration).to eq(14.days)
  end
end
