require "rails_helper"

RSpec.describe "Orders", type: :request do
  let!(:product) { create(:product, price: "100.00", stock: 5) }
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

  def post_order(order: customer)
    post orders_path, params: {
      idempotency_key: SecureRandom.uuid,
      order:,
      items: [ { product_id: product.id, quantity: 2 } ]
    }
  end

  describe "POST /orders" do
    it "creates the order, decrements stock and redirects to the confirmation by token" do
      expect { post_order }.to change(Order, :count).by(1)

      expect(response).to redirect_to(order_path(Order.last.token))
      expect(product.reload.stock).to eq(3)
    end

    it "re-renders the form with 422 when the email is missing" do
      expect { post_order(order: customer.except(:email)) }.not_to change(Order, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(product.reload.stock).to eq(5)
    end
  end

  describe "GET /orders/:token" do
    it "returns 404 for a non-existent token" do
      get order_path("neexistujici-token")

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /orders/:token/cancel" do
    it "cancels the order and redirects to its confirmation page" do
      order = create(:order)

      post cancel_order_path(order.token)

      expect(response).to redirect_to(order_path(order.token))
      expect(order.reload).to be_cancelled
    end
  end
end
