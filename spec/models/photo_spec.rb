require 'spec_helper'

describe Photo do
  
  validate_timestamps
  
  describe "relationships" do
    it { should be_embedded_in(:order) }
    it { should embed_one(:specification) }
    it { should belong_to(:product) }
    it { should belong_to(:image) }
  end
  
  describe "validations" do
    it "should not be valid without a product" do
      order = Fabricate :order
      photo = order.photos.create :count => 5, :specification_attributes => { :paper => :glossy }, :product_id => nil
      photo.should_not be_valid
      photo.errors[:product].should_not be_blank
    end
  end
  
  describe "directory" do
      
    let!(:product){ Fabricate :product, :name => "10x15" }
    let!(:order){ Fabricate :order }
    let!(:photo){ order.photos.create :count => 5, :specification_attributes => { :paper => :glossy }, :product_id => product.id }
    
    it "has the correct name" do
      photo.directory.name.should == "P00510x15OBNN"
    end
    
  end

end
