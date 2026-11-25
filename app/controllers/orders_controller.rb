class OrdersController < ApplicationController
  def new
    @order = Order.new
    quantities = params[:product_id] ? { params[:product_id].to_i => 1 } : {}
    prepare_form(quantities:, idempotency_key: SecureRandom.uuid)
  end

  def create
    result = Orders::PlaceOrder.new(
      customer: customer_params.to_h,
      items: items_params,
      idempotency_key: params[:idempotency_key]
    ).call

    if result.success?
      redirect_to order_path(result.order.token)
    else
      @order = result.order || Order.new(customer_params)
      @error_message = result.message
      prepare_form(
        quantities: items_params.to_h { |item| [ item[:product_id].to_i, item[:quantity] ] },
        idempotency_key: params[:idempotency_key]
      )
      render :new, status: :unprocessable_content
    end
  end

  def show
    @order = Order.includes(line_items: :product).find_by!(token: params[:token])
  end

  private

  def prepare_form(quantities:, idempotency_key:)
    @products = Product.order(:name)
    @quantities = quantities
    @idempotency_key = idempotency_key
  end

  def customer_params
    params.expect(order: %i[customer_name email phone street city postal_code country])
  end

  def items_params
    params.permit(items: %i[product_id quantity]).fetch(:items, [])
  end
end
