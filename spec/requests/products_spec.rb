require "rails_helper"

RSpec.describe "Products", type: :request do
  describe "GET /" do
    it "lists products with price and availability" do
      create(:product, name: "Guitar", price: "1234.50", stock: 2)
      create(:product, name: "Drum", stock: 0)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Guitar", "1 234,50 Kč", "Skladem 2 ks", "Drum", "Vyprodáno")
    end
  end

  describe "GET /products/:id" do
    it "shows the product detail" do
      product = create(:product, name: "Guitar", description: "Acoustic guitar")

      get product_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Guitar", "Acoustic guitar")
    end

    it "returns 404 for a non-existent product" do
      get product_path(id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end
end
