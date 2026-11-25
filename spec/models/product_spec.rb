require "rails_helper"

RSpec.describe Product do
  it "strips whitespace around the name" do
    expect(build(:product, name: "  Guitar  ").name).to eq("Guitar")
  end

  it "rejects negative stock" do
    product = build(:product, stock: -1)

    expect(product).not_to be_valid
    expect(product.errors[:stock]).to be_present
  end

  it "rejects negative price" do
    product = build(:product, price: -1)

    expect(product).not_to be_valid
    expect(product.errors[:price]).to be_present
  end

  describe "name uniqueness" do
    before { create(:product, name: "Guitar") }

    it "rejects the same name in different letter case" do
      expect(build(:product, name: "GUITAR")).not_to be_valid
    end

    it "is enforced by the database when validations are bypassed" do
      expect { build(:product, name: "guitar").save!(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  it "has negative stock rejected by the database when validations are bypassed" do
    product = create(:product)

    expect { product.update_column(:stock, -1) }
      .to raise_error(ActiveRecord::StatementInvalid, /products_stock_non_negative/)
  end
end
