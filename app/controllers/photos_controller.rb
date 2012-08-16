class PhotosController < ApplicationController

  before_filter :authenticate_user!#, :except => :index
  #before_filter :create_and_sign_in_anonymous_user, :only => :index

  def create
    order = current_user.orders.find params[:order_id]
    count = params[:count].to_i

    @photo = nil

    ids   = []

    count.times do
      @photo = order.photos.build filter_photo_params_for_creation params[:photo]
      @photo.save! if not @photo.valid?
    end
    
    count.times do
      @photo.save
      ids << @photo.id
    end

    success :photo_ids => ids
  rescue Mongoid::Errors::Validations => exception
    render :status => :unprocessable_entity, :json => {:errors => @photo.errors, :exception => exception}
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
      photo_params.keep_if{ |k,v| ["count", "product_id", "specification_attributes"].include? k }
    end

end
