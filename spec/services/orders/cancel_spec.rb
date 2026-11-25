require "rails_helper"

RSpec.describe Orders::Cancel do
  let(:product) { create(:product, stock: 3) }
  let(:order) { create(:order) }

  before { create(:line_item, order:, product:, quantity: 2) }

  it "cancels a pending order and restores the stock" do
    result = described_class.new(order).call

    expect(result).to be_success
    expect(order.reload).to be_cancelled
    expect(product.reload.stock).to eq(5)
  end

  it "returns not_cancellable on a second cancel and does not restore the stock again" do
    described_class.new(order).call

    result = described_class.new(order).call

    expect(result).not_to be_success
    expect(result.error).to eq(:not_cancellable)
    expect(result.message).to be_present
    expect(product.reload.stock).to eq(5)
  end

  it "enqueues the cancellation e-mail" do
    expect { described_class.new(order).call }
      .to have_enqueued_mail(OrderMailer, :cancellation)
  end

  it "does not enqueue another e-mail on a second cancel" do
    described_class.new(order).call

    expect { described_class.new(order).call }
      .not_to have_enqueued_mail(OrderMailer, :cancellation)
  end
end
