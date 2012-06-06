class Image
  include Mongoid::Document
  
  attr_accessible :image, :image_cache
  
  mount_uploader :image, ImageUploader
end
