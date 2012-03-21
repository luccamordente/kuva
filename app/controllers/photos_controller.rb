class PhotosController < ApplicationController
  def index
    u = User.first
    o = u.orders.first
    @photos = o
  end

  def create
    puts 'received' + params.inspect
    u = User.first
    o = u.orders.first || u.orders.create
    p = o.photos.new               
    p.image = params[:Filedata]
    p.save
    render :text => 1
  end                        

  def check
    render :text => 0
  end       
end   
