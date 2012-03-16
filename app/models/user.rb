class User
  include Mongoid::Document

  field :name, :type => String
  field :password, :type => String
  field :email, :type => String
   
  embeds_many :orders
                      
end
