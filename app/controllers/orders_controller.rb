class OrdersController < ApplicationController
  
  def close
    @order = Order.find params[:id]
    @order.close
    
    success :id => @order.id.to_s 
  end
  
end
