class PhotosController < ApplicationController
  
  before_filter :authenticate_user!#, :except => :index
  #before_filter :create_and_sign_in_anonymous_user, :only => :index
  
  def index
    @order = current_user.orders.create
  end

  def create
    order = current_user.orders.find params[:order_id]
    count = params[:count].to_i
    
    ids   = []
    
    count.times do
      photo = order.photos.create filter_photo_params_for_creation params[:photo]
      ids  << photo.id
    end
    
    success :photo_ids => ids
  end
  
  def update
    order = current_user.orders.find params[:order_id]
    @photo = order.photos.find params[:id]
    if @photo.update_attributes! params[:photo]
      success :id => @photo.id.to_s
    end
  end

  def check
    render :text => 0
  end
  
  private
  
    def create_and_sign_in_anonymous_user
      sign_in User.create_anonymous_user unless user_signed_in?
    end
    
    def filter_photo_params_for_creation photo_params
      photo_params.keep_if{ |k,v| ["count", "spec", "product_id", "spec_attributes"].include? k }
    end
  
end
