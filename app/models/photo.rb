class Photo
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :name, :border, :margin, :count, :product_id, :image_id, :specification_attributes, :failed

  field :name  , type: String
  field :count , type: Integer, default: 0
  field :border, type: Boolean, default: false
  field :margin, type: Boolean, default: false
  field :failed, type: Boolean, default: false

  embedded_in :order
  embeds_one  :specification

  accepts_nested_attributes_for :specification

  # relationships
  belongs_to :product
  belongs_to :image

  # validations
  validates :product, presence: true

  # scopes
  scope :without_image, where(image_id: nil)
  scope :not_failed   , where(failed: false)

  # callbacks
  before_save   :check_for_image
  before_save   :update_order_price
  after_destroy :update_order_price

  after_save 'self.order.check_and_update_status'



  def directory
    @directory ||= Directorizer.new(self)
  end

  def self.mark_failed
    update_all failed: true
  end

private

  def update_order_price
    order.update_price
  end

  def check_for_image
    self.failed = false if self.image.present?
    true
  end

end
