class OrdersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_specs, :load_products, only: :new

  def new
    @order = current_user.orders.create

    render layout: false
  end

  def index
    @orders = current_user.orders.without(:photos).order_by(:updated_at.desc).all
  end

  def close
    @order = current_user.orders.find params[:id]
    @order.update_status Order::CLOSED

    success id: @order.id.to_s
  end

  def cancel
    @order = current_user.orders.find params[:id]
    @order.update_status Order::CANCELED

    success id: @order.id.to_s
  end

private

  def load_specs
    @specs = Specification.to_h
  end

  def load_products
    @products = Product.only(:_id,:name,:price, :dimensions).asc(:dimensions).all
  end

end
