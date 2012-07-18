class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
                  
  field :name , :type => String
  field :count, :type => Integer
  
  accepts_nested_attributes_for :specification
  
  embedded_in :order
  embeds_one  :specification
  
  belongs_to :product 
  belongs_to :image
  
  validates :product, :presence => true
  
  after_save lambda{ self.order.check_and_update_status }
  
  def directory
    @directory ||= Directorizer.new(self)
  end
  
  
  
end
