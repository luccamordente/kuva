class Admin::PhotosController < Admin::ApplicationController
  before_filter :find_photo


  def show
  end

  def download
    original = ! params[:original].nil?

    image = @photo.image.image
    image = image.original if original

    file  = File.open image.current_path
    name  = File.basename file.path

    send_data file.read, filename: name
  end

  private
  def find_photo
    @photo = Order.find(params[:order_id]).photos.find(params[:id]) if params[:id] && params[:order_id]
  end
end