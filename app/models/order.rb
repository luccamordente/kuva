class Order
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # attrs
  attr_protected :status
  
  # fields
  field :status      , :type => Symbol
  field :empty_at    , :type => DateTime
  field :progress_at , :type => DateTime
  field :closed_at   , :type => DateTime
  field :catching_at , :type => DateTime
  field :caught_at   , :type => DateTime
  field :ready_at    , :type => DateTime
  field :delivered_at, :type => DateTime
  
  # relationships
  embeds_many :photos
  belongs_to  :user, :index => true
  has_many    :images
  
  # statuses
  EMPTY     = :empty     # just created
  PROGRESS  = :progress  # selecting/sending process
  CLOSED    = :closed    # everythig was sent and is ready to be caught
  CATCHING  = :catching  # is being caught by client application
  CAUGHT    = :caught    # was caught by client application
  READY     = :ready     # was excecuted and is ready to deliver to customer
  DELIVERED = :delivered # in its way to customer
  
  STATUSES  = [ EMPTY, PROGRESS, CLOSED, CATCHING, CAUGHT, READY, DELIVERED ]
  
  # validations
  validates :status, :inclusion => { :in => STATUSES }, :allow_blank => false
  
  # filters
  before_validation :set_empty_status, :on => :create
  
  
  def check_and_update_status
    update_status self.class::PROGRESS if (self.photos.count > 0 || self.images.count > 0) && self.status == self.class::EMPTY
  end
    
  def update_status status
    self.status = status
    self.send :"#{status}_at=", Time.now
    save
  end
  
  
  private
  
    def set_empty_status
      self.status = self.class::EMPTY unless self.status.present?
    end
  
end
