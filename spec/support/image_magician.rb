class ImageMagician

  def initialize file
    @file = file
  end

  def original_file
    @file
  end

  def original_image
    magick
  end

  def image
    @image ||= Fabricate :image, image: original_file
  end

  def converted_image
    image.magick
  end

private

  def magick
    Magick::Image.read(@file.path).first
  end

end