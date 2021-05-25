class OrdersController < ApplicationController
  before_action :find_product, only: :add_product
  before_action :find_order, only: %i[show purchase checkout success]
  before_action :redirect_checkout, only: %i[show success]
  def index
    @orders = Order.all
  end

  def show; end

  def checkout; end

  def add_product
    @order = Order.new(customer_email: Faker::Internet.email, status: :pending)
    @order.line_items.new(product: @product, price: @product.price, quantity: 1)
    @order.save!

    redirect_to action: :checkout, id: @order.token
  end

  def success; end

  def purchase
    puts request.referer

    payment = @order.payments.create(amount: @order.amount)
    payment_methods = ['pagolatam', 'webpayplus']

    data = {
      'pl_service_token': ENV['PAGOLATAM_SERVICE_TOKEN'],
      'pl_amount': @order.amount.to_i,
      'pl_currency': 'CLP',
      'pl_order_id': @order.token,
      'pl_customer_email': @order.customer_email,
      'pl_complete_url': success_order_url(id: @order.token),
      'pl_cancel_url': checkout_order_url(id: @order.token),
      'pl_callback_url': notify_pagolatam_index_url,
      'pl_shop_country': 'CL',
      'pl_session_id': payment.token
    }


    signature = OpenSSL::HMAC.hexdigest('sha256', ENV['PAGOLATAM_SECRET_TOKEN'], data.sort.join)

    response = HTTParty.post(ENV['PAGOLATAM_URL'] + "/transactions",
    {
      headers: { "Content-Type" => "application/json" },
      body: data.merge('pl_signature': signature).to_json
    })

    if response.code == 200 && response&.parsed_response['urls'].present? && response&.parsed_response['urls'][payment_methods[params['pm_id'].to_i - 1]]
      redirect_to response&.parsed_response['urls'][payment_methods[params['pm_id'].to_i - 1]]
    else
      redirect_to action: :checkout, id: @order.token
    end
  end

  private

  def find_order
    @order = Order.find_by!(token: params[:id])
  end

  def find_product
    @product = Product.find(params[:product_id])
  end

  def redirect_checkout
    unless @order.status == 'confirmed'
      redirect_to checkout_order_path(id: @order.token)
    end
  end
end
