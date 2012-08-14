class ImagesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, :only => :create

  def create
    order = current_user.orders.find params[:order_id]  

    @image = order.images.build params
    @image.save!

    success :id => @image.id
  rescue Mongoid::Errors::Validations => exception
    render :status => :unprocessable_entity, :json => {:errors => @image.errors, :exception => exception}
  end

end
