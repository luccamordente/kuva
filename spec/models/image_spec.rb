require 'spec_helper'

describe Image do
  
  validate_timestamps
  
  describe "relationships" do
    it { should belong_to(:order) }
  end
  
  describe "validations" do
    it "should no be valid without image" do
      image = Fabricate.build :image, image: nil
      image.should_not be_valid
      image.errors[:image].should_not be_nil
    end
  end
  
  
  describe "upload" do
    
    context "of non rgb images" do
      it "converts to sRGB profile"
    end
    
    context "of rgb image" do
      it "keeps the original profile"
    end
    
    context "of non jpeg image" do
      it "converts to jpeg"
    end
    
    context "of jpeg image" do
      it "does not convert image format"
    end
    
  end
  
end
