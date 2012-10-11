class Directorizer

  DEFAULT_COLOR  = "O"
  DEFAULT_BORDER = "N"
  DEFAULT_MARGIN = "N"

  def initialize photo
    @photo = photo
  end

  def name
    "P#{count}_#{size}_#{color}#{paper}#{border}#{margin}"
  end

  def count
    "%03d" % photo.count
  end

  def size
    @photo.product.name
  end

  def color
    DEFAULT_COLOR
  end

  def paper
    @photo.specification.paper_to_directory_string
  end

  def border
    DEFAULT_BORDER
  end

  def margin
    DEFAULT_MARGIN
  end

  def photo
    @photo
  end

end