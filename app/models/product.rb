class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name       , :type => String
  field :price      , :type => Float
  field :description, :type => String
  field :image      , :type => String
  field :dimensions , :type => Hash
  
end
