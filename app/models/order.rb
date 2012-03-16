class Order
  include Mongoid::Document  
  embeds_many :photos
  embedded_in :user
end
