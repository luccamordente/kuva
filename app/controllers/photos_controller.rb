class PhotosController < ApplicationController
  
  before_filter :authenticate_user!
  
  def index
    @order = current_user.orders.first
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
  
end
