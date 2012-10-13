class ImageMagician

  def initialize file
    @file = file
  end

  def file_before
    @file
  end

  def image_before
    magick file_before.path
  end

  def image
    @image ||= Fabricate(:image, image: file_before).image
  end

  def image_after
    magick image.current_path
  end

  def original_image_after
    magick image.original.current_path
  end

private

  def magick path
    Magick::Image.read(path).first
  end

end