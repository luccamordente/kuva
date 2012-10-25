require 'fileutils'

class Orderizer

  def initialize order
    @order = order
  end

  def compressed options = {}, &block
    originals = !!options[:originals]

    base_directory = create_base_directory

    place_photos_to base_directory, originals
    file = compress base_directory

    if block_given?
      yield file
      delete_compressed
    end

    file
  rescue
    raise
  ensure
    delete_base_directory
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
    system "rm -rf #{@order.tmp_path}"
  end

  def delete_compressed
    FileUtils.rm @order.tmp_zip_path
  end

  def place_photos_to directory, originals = false
    @order.photos.each do |photo|
      next if photo.count.zero?

      photo_dir = photo.directory.name

      Dir.chdir directory.path
      Dir.mkdir photo_dir unless File.directory? photo_dir

      raise "Photo has no Image" unless photo.image.present?

      image         = photo.image.image
      image_to_copy = originals && image.original.present? ? image.original : image

      file_path  = image_to_copy.current_path
      file_name  = File.basename(file_path)
      file_ext   = File.extname(file_name)
      dest_match = file_name.chomp(file_ext)

      # verifies if file exists and then rename it putting an incremental integer after the name
      dest_path  = (existing = Dir["#{photo_dir}/#{dest_match}*"].last) ?
                    File.join(photo_dir, "#{dest_match}[#{(File.basename(existing).chomp(file_ext).gsub(dest_match,'').gsub(/[\[\]]/,'').to_i + 1)}]#{file_ext}") :
                    photo_dir

      FileUtils.cp image_to_copy.current_path, dest_path
    end
  end


end