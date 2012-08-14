require 'spec_helper'

describe Product do
  
  describe "validations" do
    validate_timestamps
    it "should not be valid without product id"
  end
  
  describe "relationships" do
    # it { should have_many(:photos) }
  end
  

end
