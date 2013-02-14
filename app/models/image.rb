class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :image, :image_cache

  mount_uploader :image, ImageUploader

  belongs_to :order

  validates :image, presence: true, on: :create

  after_save "self.order.check_and_update_status if self.order.present?"

  before_destroy :remove_image!


  def magick
    Magick::Image.read(self.image.current_path).first
  end

end
