class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  
  attr_protected :status
  
  field :status, :type => Symbol
  
  embeds_many :photos
  belongs_to  :user, :index => true
  has_many    :images
  
  EMPTY     = :empty     # just created
  PROGRESS  = :progress  # selecting/sending process
  CLOSED    = :closed    # everythig was sent and is ready to be caught
  CATCHING  = :catching  # is being caught by client application
  CAUGHT    = :caught    # was caught by client application
  READY     = :ready     # was excecuted and is ready to deliver to customer
  DELIVERED = :delivered # is on customers hand
  
  validates :status, :inclusion => { :in => [EMPTY, PROGRESS, CLOSED, CATCHING, CAUGHT, READY, DELIVERED] }, :allow_blank => false
  
  before_validation :set_empty_status, :on => :create
  
  
  def check_and_update_status
    update_status self.class::PROGRESS if (self.photos.count > 0 || self.images.count > 0) && self.status == self.class::EMPTY
  end
  
  def close
    update_status self.class::CLOSED
  end
  
  
  private
  
    def set_empty_status
      self.status = self.class::EMPTY unless self.status.present?
    end
    
    def update_status status
      update_attribute :status, status
    end
  
end
