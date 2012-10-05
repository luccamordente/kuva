class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name       , type: String
  field :price      , type: Float , default: 0
  field :description, type: String
  field :image      , type: String
  field :dimensions , type: Array

  validates :name, :price, :dimensions, :presence => true

  before_save "self.dimensions.sort!"


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

end
