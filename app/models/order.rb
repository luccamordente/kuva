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
  
  scope :last_updated, all(:sort => [[:updated_at, :desc]])
  
  # filters
  before_validation :set_empty_status, :on => :create
  before_create :notify_opened
  before_save :notify_closed, :if => :closed?
  
  
  def check_and_update_status
    update_status self.class::PROGRESS if (self.photos.count > 0 || self.images.count > 0) && is_empty?
  end
    
  def update_status status
    self.status = status
    self.send :"#{status}_at=", Time.now
    save
  end
  
  def downloadable?
    not [EMPTY, PROGRESS].include? status
  end
  
  def is_empty?; self.status == EMPTY ; end
  def closed?  ; self.status == CLOSED; end
  
  
  private
  
    def set_empty_status
      set_status EMPTY unless self.status.present?
    end
    
    def set_status status
      self.status = status
    end
    
    def notify_opened
      OrderMailer.opened(self).deliver
    end
    
    def notify_closed
      OrderMailer.closed(self).deliver
    end
  
end
