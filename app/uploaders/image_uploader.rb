# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  INTENT  = 'Relative'
  PROFILE = "#{Rails.root}/lib/profiles/srgb.icm"

  FORMATS_WHITELIST     = [ 'JPEG' ]
  COLORSPACES_WHITELIST = [ Magick::RGBColorspace, Magick::SRGBColorspace ]

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  after :store, :convert

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if Rails.env.production?
      "#{Rails.root}/../../shared/uploads/orders/#{model.order_id}"
    else
      "#{Rails.root}/tmp/uploads/orders/#{model.order_id}"
    end
  end



  def convert file
    path  = model.image.current_path
    image = Magick::Image.read(path).first

    convert_format     = ! FORMATS_WHITELIST.include?(image.format)
    convert_colorspace = true # ! COLORSPACES_WHITELIST.include?(image.colorspace)

    options  = []
    options << '-format  jpg'        if convert_format
    options << "-intent  #{INTENT}"  if convert_colorspace
    options << "-profile #{PROFILE}" if convert_colorspace

    command = "convert #{path} #{options.join(' ')} #{path.chomp(File.extname(path))}.jpg"
    system command
  end


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process scale: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{original_filename.chomp(File.extname(original_filename))}.jpg" if original_filename
  end

end
