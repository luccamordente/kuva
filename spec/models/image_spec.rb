require 'spec_helper'

describe Image do
  
  validate_timestamps
  
  describe "relationships" do
    it { should belong_to(:order) }
  end
  
  describe "validations" do
    it "should no be valid without image" do
      image = Factory.build :image, :image => nil
      image.should_not be_valid
      image.errors[:image].should_not be_nil
    end
  end
  
end
