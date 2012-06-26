class OrdersController < ApplicationController
  
  before_filter :authenticate_user!
  
  before_filter :load_specs, :load_products, :only => :open
  
  def open
    @order = current_user.orders.create
  end
  
  def close
    @order = current_user.orders.find params[:id]
    @order.close
    
    success :id => @order.id.to_s 
  end
  
  
  private
  
  def load_specs
    @specs = Spec.to_h
  end
  
  def load_products
    @products = Product.only(:_id,:name,:price).all
  end

  
end
