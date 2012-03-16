class Photo
  include Mongoid::Document
  embedded_in :order
  mount_uploader :image, PhotoUploader
                  
  field :name, :type => String
  field :species, :type => Hash
end
