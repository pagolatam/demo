class OrdersController < ApplicationController
  before_action :find_product, only: :add_product
  before_action :find_order, only: %i[show purchase]

  def index
    @orders = Order.all
  end

  def show
    @order = Order.find_by!(token: params[:id])
  end

  def add_product
    @order = Order.new(customer_email: Faker::Internet.email)
    @order.line_items.new(product: @product, price: @product.price, quantity: 1)
    @order.save

    redirect_to action: :show, id: @order.token
  end

  def purchase

  end

  private

  def find_order
    @order = Order.find_by!(token: params[:id])
  end

  def find_product
    @product = Product.find(params[:product_id])
  end
end
