class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :image, :image_cache

  mount_uploader :image   , ImageUploader

  belongs_to :order

  validates :image, presence: true

  after_save "self.order.check_and_update_status if self.order.present?"


  def magick
    Magick::Image.read(self.image.current_path).first
  end

end
