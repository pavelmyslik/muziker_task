require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "#confirmation" do
    let(:order) { create(:order, email: "jan@example.com", total: "1234.50") }
    let(:mail) { described_class.confirmation(order) }

    before { create(:line_item, order:, quantity: 1) }

    it "is sent to the customer's e-mail" do
      expect(mail.to).to eq([ "jan@example.com" ])
    end

    it "contains the order total and the link to the order" do
      body = mail.text_part.decoded

      expect(body).to include("1 234,50 Kč")
      expect(body).to include("/orders/#{order.token}")
    end
  end
end
