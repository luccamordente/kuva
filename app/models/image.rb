class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :image, :image_cache
  mount_uploader :image, ImageUploader

  belongs_to :order

  validates :image, presence: true

  after_save "self.order.check_and_update_status if self.order.present?"

end
