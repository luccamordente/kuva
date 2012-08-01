class OrdersController < ApplicationController
  
  before_filter :authenticate_user!
  
  before_filter :load_specs, :load_products, :only => :open
  
  def open
    @order = current_user.orders.create
  end
  
  def close
    @order = current_user.orders.find params[:id]
    @order.update_status Order::CLOSED
    
    success :id => @order.id.to_s
  end
  
  def download
    # load order
    # compress order to zip
    # stram order
    # remove zip
  end
  
  private
  
  def load_specs
    @specs = Specification.to_h
  end
  
  def load_products
    @products = Product.only(:_id,:name,:price).all
  end
  
end
