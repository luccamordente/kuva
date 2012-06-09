class Spec
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :paper, :type => String
  
  belongs_to  :product
  embedded_in :photo
  
end
