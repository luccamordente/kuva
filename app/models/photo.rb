class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
                  
  field :name   , :type => String
  field :species, :type => Hash
  
  mount_uploader :image, PhotoUploader
  
  embedded_in :order
  embeds_many :specs
end
