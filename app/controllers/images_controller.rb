class ImagesController < ApplicationController
  
  before_filter :authenticate_user!
  
  def create
    order = Order.find params[:order_id]
    
    @image = order.images.build params[:image]
    @image.save!
    
    success :id => @image.id  
  rescue Mongoid::Errors::Validations => exception
    render :status => :unprocessable_entity, :json => {:errors => @image.errors, :exception => exception}
  end

  
end
