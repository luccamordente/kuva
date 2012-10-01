module Length

  CENTIMETER = 10
  DECIMETER  = CENTIMETER * 10
  METER      = DECIMETER  * 10
  DECAMETER  = METER      * 10
  HECTOMETER = DECAMETER  * 10
  KILOMETER  = HECTOMETER * 10

  def mm
    self
  end
  alias :millimeter  :mm
  alias :millimeters :mm

  def cm
    self * CENTIMETER
  end
  alias :centimeter  :cm
  alias :centimeters :cm

  def dm
    self * DECIMETER
  end
  alias :decimeter  :dm
  alias :decimeters :dm

  def m
    self * METER
  end
  alias :meter  :m
  alias :meters :m

  def dam
    self * DECAMETER
  end
  alias :decameter  :dam
  alias :decameters :dam

  def hm
    self * HECTOMETER
  end
  alias :hectometer  :hm
  alias :hectometers :hm

  def km
    self * KILOMETER
  end
  alias :kilometer   :km
  alias :kilometers  :km

end


Numeric.send :include, Length
