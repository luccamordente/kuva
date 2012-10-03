class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable,
  # REMOVIDO MANUALMENTE: :registerable
  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable,
         :token_authenticatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Encryptable
  # field :password_salt, type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  # Token authenticatable
  field :authentication_token, type: String

  field :name, type: String
  field :password, type: String
  field :email, type: String

  field :anonymous, type: Boolean, default: false

  validates :name, presence: true

  has_many :orders, dependent: :destroy

  before_save :ensure_authentication_token
  after_create "generate_reset_password_token! if should_generate_reset_token?"


  def self.create_anonymous_user
    temp_token = SecureRandom.base64(15).tr('+/=', 'xyz')
    user = ::User.new(email: "#{temp_token}@kuva.com", password: temp_token, password_confirmation: temp_token, anonymous: true)
    user.save!(validate: false)
    user
  end

  def move_to another_user
    raise "Registered users cannot be moved." unless self.anonymous?
    self.orders.each { |order| another_user.orders << order }
    another_user.save && self.reload.destroy
  end

private

  def send_welcome_mail_with_password_instructions
    UserMailer.welcome_with_password_instructions(self).deliver
  end

end
