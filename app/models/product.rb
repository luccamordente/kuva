class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :price, :dimension1, :dimension2

  field :name       , type: String
  field :price      , type: Float , default: 0
  field :description, type: String
  field :image      , type: String
  field :dimensions , type: Array

  validates :name, :price, :dimensions, presence: true
  validates_numericality_of :price, :dimension1, :dimension2, greater_than: 0

  before_validation :update_dimensions
  before_save 'self.dimensions.sort!'


  def horizontal_dimensions
    { width: dimensions[1], height: dimensions[0] }
  end

  def vertical_dimensions
    { width: dimensions[0], height: dimensions[1] }
  end

  def as_json options = nil
    options ||= {}
    options[:methods] = ((options[:methods] || []) + [:horizontal_dimensions, :vertical_dimensions])
    super options
  end

  def dimension1
    @dimension1 || dimensions.try(:[], 0)
  end

  def dimension2
    @dimension2 || dimensions.try(:[], 1)
  end

  def dimension1= size
    @dimension1 = size
  end

  def dimension2= size
    @dimension2 = size
  end

  def price= price
    super price.to_s.gsub /[^\d]+/, '.'
  end


private

  def update_dimensions
    if @dimension1.present? and @dimension2.present?
      self.dimensions = [ @dimension1, @dimension2 ].sort
      self.name       = "#{dimensions[0]}x#{dimensions[1]}"
    end
  end

end
