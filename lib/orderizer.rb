require 'fileutils'

class Orderizer
  
  def initialize order
    @order = order
  end
  
  def compressed
    base_directory = create_base_directory
    
    place_photos_to base_directory
    compress        base_directory
  end

private

  def compress directory
    Dir.chdir Order.tmp_path
    system "zip -r #{@order.tmp_zip_identifier} #{@order.tmp_identifier} > /dev/null"
    delete_base_directory
    File.new @order.tmp_zip_path
  end
  
  def create_base_directory
    Dir.mkdir @order.tmp_path
    Dir.new @order.tmp_path
  end
  
  def delete_base_directory
    FileUtils.rm_rf @order.tmp_path
  end
  
  def place_photos_to directory
    @order.photos.each do |photo|
      Dir.chdir directory.path
      Dir.mkdir photo.directory.name unless File.directory? photo.directory.name
      FileUtils.cp photo.image.image.current_path, photo.directory.name
    end
  end
  
  
end