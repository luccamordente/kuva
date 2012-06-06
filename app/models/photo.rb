class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
                  
  field :name , :type => String
  field :count, :type => Integer
  
  accepts_nested_attributes_for :spec
  
  embedded_in :order
  embeds_one  :spec
  
  belongs_to :product 
  belongs_to :image
end
