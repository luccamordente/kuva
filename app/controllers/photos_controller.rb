class PhotosController < ApplicationController
  
  before_filter :authenticate_user!, :except => :index
  before_filter :create_and_sign_in_anonymous_user, :only => :index
  
  def index
    @order = current_user.orders.create
  end

  def create
    puts 'received' + params.inspect
    o = current_user.orders.first || current_user.orders.create
    p = o.photos.new
    p.image = params[:Filedata]
    p.save
    render :text => 1
  end

  def check
    render :text => 0
  end
  
  private
  
    def create_and_sign_in_anonymous_user
      sign_in User.create_anonymous_user unless user_signed_in?
    end
  
end
