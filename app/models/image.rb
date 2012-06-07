class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  
  attr_accessible :image, :image_cache
  mount_uploader :image, ImageUploader

  validates :image, :presence => true
  
  belongs_to :order
  
end
