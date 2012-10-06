class Photo
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name , type: String
  field :count, type: Integer, default: 0

  embedded_in :order
  embeds_one  :specification

  accepts_nested_attributes_for :specification

  belongs_to :product
  belongs_to :image

  validates :product, presence: true

  before_save   :update_order_price
  after_destroy :update_order_price

  after_save 'self.order.check_and_update_status'


  def directory
    @directory ||= Directorizer.new(self)
  end

private

  def update_order_price
    order.update_price
  end

end
