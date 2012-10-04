require 'fileutils'

class Orderizer

  def initialize order
    @order = order
  end

  def compressed &block
    base_directory = create_base_directory

    place_photos_to base_directory
    file = compress base_directory

    yield file if block_given?

    file
  rescue
    delete_base_directory
    raise
  ensure
    delete_compressed if file
  end

private

  def compress directory
    Dir.chdir Order.tmp_path
    system "zip -r #{@order.tmp_zip_identifier} #{@order.tmp_identifier} > /dev/null"
    File.open @order.tmp_zip_path
  end

  def create_base_directory
    Dir.mkdir @order.tmp_path
    Dir.new @order.tmp_path
  end

  def delete_base_directory
    FileUtils.rm_rf @order.tmp_path
  end

  def delete_compressed
    FileUtils.rm @order.tmp_zip_path
  end

  def place_photos_to directory
    @order.photos.each do |photo|
      Dir.chdir directory.path
      Dir.mkdir photo.directory.name unless File.directory? photo.directory.name
      raise "Photo has no Image" unless photo.image.present?
      FileUtils.cp photo.image.image.current_path, photo.directory.name
    end
  end


end