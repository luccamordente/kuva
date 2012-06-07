class ImagesController < ApplicationController
  
  before_filter :authenticate_user!
  
  def create
    order = Order.find params[:order_id]
    
    image = order.images.create params[:image]
    
    success :id => image.id
  end

  
end
