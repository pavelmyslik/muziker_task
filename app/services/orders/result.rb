module Orders
  Result = Data.define(:order, :error, :message) do
    def self.success(order) = new(order:, error: nil, message: nil)
    def self.failure(error, message, order = nil) = new(order:, error:, message:)

    def success? = error.nil?
  end
end
