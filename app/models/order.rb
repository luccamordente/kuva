class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embeds_many :photos
  belongs_to  :user, :index => true
  has_many    :images
end
