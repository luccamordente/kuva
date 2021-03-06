class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  include Kuva::Maid


  EXECUTION_TIME = 1.hour

  paginates_per 50

  # attrs
  attr_accessible :price, :observations, :user_id
  attr_protected :status

  # fields
  field :status      , type: Symbol
  field :price       , type: Float   , default: 0
  field :empty_at    , type: DateTime
  field :progress_at , type: DateTime
  field :closed_at   , type: DateTime
  field :catching_at , type: DateTime
  field :caught_at   , type: DateTime
  field :ready_at    , type: DateTime
  field :delivered_at, type: DateTime
  field :canceled_at , type: DateTime
  field :recatch_at  , type: DateTime
  field :observations, type: String

  auto_increment :sequence
  index sequence: 1

  # relationships
  embeds_many :photos
  belongs_to  :user  , index: true
  has_many    :images, dependent: :destroy

  # statuses
  EMPTY     = :empty     # just created
  PROGRESS  = :progress  # selecting/sending process
  CLOSED    = :closed    # everythig was sent and is ready to be caught
  CATCHING  = :catching  # is being caught by client application
  CAUGHT    = :caught    # was caught by client application
  READY     = :ready     # was excecuted and is ready to deliver to customer
  DELIVERED = :delivered # in its way to customer
  CANCELED  = :canceled  # canceled by the customer
  RECATCH   = :recatch   # must be caught again
  STATUSES  = [ EMPTY, PROGRESS, CLOSED, CATCHING, CAUGHT, READY, DELIVERED, CANCELED, RECATCH ]

  # validations
  validates :status, inclusion: { in: STATUSES }, allow_blank: false

  # scopes
  scope :last_updated, order_by(:updated_at.desc)
  scope :last_opened , order_by(:created_at.desc)
  scope :good_to_catch, where(:status.in => [Order::CLOSED, Order::RECATCH])

  # filters
  before_validation :set_empty_status, on: :create
  # notifications
  # before_create :admin_notify_opened
  # before_save   :admin_notify_closed,     if: lambda{ closed? and not was_closed? }
  # before_save   :admin_notify_closed_ios, if: lambda{ closed? and not was_closed? }
  # before_save   :user_notify_closed ,     if: lambda{ closed? and not was_closed? }

  def close
    mark_failed
    update_price
    update_status Order::CLOSED
    self
  end

  # updates price with not failed images
  def update_price
    new_price = photos.not_failed.map { |photo| photo.product.price * photo.count }.sum
    return if new_price == self.price
    update_attribute :price, new_price
  end

  def promised_for
    closed_at + EXECUTION_TIME if closed_at
  end

  def check_and_update_status
    update_status self.class::PROGRESS if (self.photos.count > 0 || self.images.count > 0) && is_empty?
  end

  def update_status status
    self.status = status
    self.send :"#{status}_at=", Time.now
    save
  end

  def downloadable?
    not [EMPTY, PROGRESS, CANCELED].include? status
  end

  def executable?
    status == CAUGHT
  end

  def deliverable?
    status == READY
  end

  def downloaded?
    [CATCHING, CAUGHT, READY, DELIVERED].include? status
  end



  def is_empty?; self.status == EMPTY ; end
  def closed?  ; self.status == CLOSED; end

  def was_closed?; status_was == self.class::CLOSED end

  def sent?
    [CLOSED, CATCHING, CAUGHT].include? status
  end

  def canceled?
    not canceled_at.nil?
  end


  # download

  def compressed options = {}, &block
    raise "Cannot compress order because it has not been closed" if closed_at.blank?

    # This should not be needed!!!
    # Photo should be updated and "failed" revalidated.
    # This can be removed after implementing a requests
    #  pool for requests comming from JS.
    update_failed_photos

    orderizer = Orderizer.new(self)
    if block_given?
      orderizer.compressed options do |file|
        yield file
      end
    else
      orderizer.compressed options
    end
  end

  def identifier options = {}
    options.symbolize_keys!
    (options[:human] ? (sequence || id) : id).to_s
  end

  def tmp_path options = {}
    File.join self.class.tmp_path, tmp_identifier(options)
  end

  def tmp_zip_path options = {}
    "#{tmp_path(options)}.zip"
  end

  def tmp_identifier options = {}
    identifier(options)
  end

  def tmp_zip_identifier options = {}
    "#{tmp_identifier(options)}.zip"
  end

  def self.tmp_path
    File.join Rails.root, "tmp"
  end

  # end download


private

    def update_failed_photos
      self.photos.failed.with_image.update_all failed: false
    end

    def mark_failed
      self.photos.without_image.mark_failed
    end

    def set_empty_status
      set_status EMPTY unless self.status.present?
    end

    def set_status status
      self.status = status
    end

    def admin_notify_opened
      AdminMailer.order_opened(self).deliver unless Rails.env.development?
    end

    def admin_notify_closed
      AdminMailer.order_closed(self).deliver unless Rails.env.development?
    end

    def admin_notify_closed_ios
      AdminMailer.order_closed_ios(self) if Rails.env.production?
    end



    def user_notify_closed
      UserMailer.order_closed(self).deliver unless Rails.env.development?
    end

end
