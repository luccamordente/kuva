class Spec
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :count, :type => Integer, :default => 0
  
  belongs_to  :product
  embedded_in :photo
  
end
