class PhotosController < ApplicationController
  def index
    
  end

  def create
    puts 'received' + params.inspect
    u = User.first
    o = u.orders.create
    p = o.photos.new
    p.image = params[:Filedata]
    p.save
    render :text => 1
  end                        

  def check
    render :text => 0
  end       
end   
