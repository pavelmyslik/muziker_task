require "rails_helper"

RSpec.describe Orders::PlaceOrder do
  let(:customer) do
    {
      customer_name: "Jan Novak",
      email: "jan@example.com",
      phone: "+420 777 123 456",
      street: "Hlavni 12",
      city: "Praha",
      postal_code: "110 00",
      country: "CZ"
    }
  end

  def place_order(items:, idempotency_key: SecureRandom.uuid, customer: self.customer)
    described_class.new(customer:, items:, idempotency_key:).call
  end

  context "with valid input" do
    let!(:guitar) { create(:product, price: "19.90", stock: 5) }
    let!(:strings) { create(:product, price: "5.00", stock: 3) }

    it "creates the order with line items, copied prices, total and decremented stock" do
      result = place_order(items: [
        { product_id: guitar.id, quantity: 2 },
        { product_id: strings.id, quantity: 1 }
      ])

      expect(result).to be_success
      order = result.order
      expect(order).to be_persisted
      expect(order.total).to eq(BigDecimal("44.80"))
      expect(order.line_items.map { |item| [ item.product, item.quantity, item.unit_price ] }).to contain_exactly(
        [ guitar, 2, BigDecimal("19.90") ],
        [ strings, 1, BigDecimal("5.00") ]
      )
      expect(guitar.reload.stock).to eq(3)
      expect(strings.reload.stock).to eq(2)
    end

    it "merges a duplicate product into a single line item with summed quantity" do
      result = place_order(items: [
        { product_id: guitar.id, quantity: 1 },
        { product_id: guitar.id, quantity: "2" }
      ])

      expect(result.order.line_items.map(&:quantity)).to eq([ 3 ])
      expect(guitar.reload.stock).to eq(2)
    end
  end

  context "when one of the products is out of stock" do
    let!(:guitar) { create(:product, stock: 5) }
    let!(:strings) { create(:product, stock: 1) }

    it "saves nothing and restores the stock of the other items" do
      result = nil

      expect {
        result = place_order(items: [
          { product_id: guitar.id, quantity: 2 },
          { product_id: strings.id, quantity: 2 }
        ])
      }.not_to change { [ Order.count, LineItem.count ] }

      expect(result.error).to eq(:out_of_stock)
      expect(result.message).to include(strings.name)
      expect(guitar.reload.stock).to eq(5)
      expect(strings.reload.stock).to eq(1)
    end
  end

  context "with the last piece in stock" do
    let!(:product) { create(:product, stock: 1) }

    it "sells it to the first order and rejects the next one" do
      first = place_order(items: [ { product_id: product.id, quantity: 1 } ])
      second = place_order(items: [ { product_id: product.id, quantity: 1 } ])

      expect(first).to be_success
      expect(second.error).to eq(:out_of_stock)
      expect(product.reload.stock).to eq(0)
    end
  end

  context "with the same idempotency key submitted twice" do
    let!(:product) { create(:product, stock: 5) }

    it "creates a single order and decrements stock once" do
      items = [ { product_id: product.id, quantity: 2 } ]
      first = nil
      second = nil

      expect {
        first = place_order(items:, idempotency_key: "same-key")
        second = place_order(items:, idempotency_key: "same-key")
      }.to change(Order, :count).by(1)

      expect(second).to be_success
      expect(second.order).to eq(first.order)
      expect(product.reload.stock).to eq(3)
    end
  end

  describe "failures" do
    let!(:product) { create(:product, stock: 5) }

    shared_examples "a failure without side effects" do |error|
      it "returns #{error} and changes nothing" do
        result = nil

        expect { result = place_order(**params) }.not_to change { [ Order.count, LineItem.count ] }
        expect(result).not_to be_success
        expect(result.error).to eq(error)
        expect(result.message).to be_present
        expect(product.reload.stock).to eq(5)
      end
    end

    %w[abc -1 2.5].each do |quantity|
      context "with invalid quantity #{quantity.inspect}" do
        let(:params) { { items: [ { product_id: product.id, quantity: } ] } }

        it_behaves_like "a failure without side effects", :invalid_quantity
      end
    end

    context "with all quantities zero or blank" do
      let(:params) { { items: [ { product_id: product.id, quantity: "0" }, { product_id: product.id, quantity: "" } ] } }

      it_behaves_like "a failure without side effects", :empty_order
    end

    context "with a non-existent product ID" do
      let(:params) { { items: [ { product_id: product.id + 1000, quantity: 1 } ] } }

      it_behaves_like "a failure without side effects", :product_not_found
    end

    context "with a non-numeric product ID" do
      let(:params) { { items: [ { product_id: "abc", quantity: 1 } ] } }

      it_behaves_like "a failure without side effects", :product_not_found
    end

    context "with a missing email" do
      let(:params) { { items: [ { product_id: product.id, quantity: 1 } ], customer: customer.merge(email: nil) } }

      it_behaves_like "a failure without side effects", :invalid_order

      it "returns the order with errors for the form" do
        result = place_order(**params)

        expect(result.order.errors[:email]).to be_present
      end
    end

    context "with a missing idempotency key" do
      let(:params) { { items: [ { product_id: product.id, quantity: 1 } ], idempotency_key: nil } }

      it_behaves_like "a failure without side effects", :invalid_order
    end
  end
end
