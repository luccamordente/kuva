require 'spec_helper'

describe Order do
  
  validate_timestamps
  
  describe "relationships" do
    it { should belong_to  :user   }
    it { should embed_many :photos }
    it { should have_many  :images }
  end
  
  describe "validation" do
    [:status].each do |attr|
      it "should not be valid without #{attr}" do
        order = Factory.create :order
        order.send "#{attr}=", nil
        order.should_not be_valid
        order.errors[attr].should_not be_nil
      end
    end
    
    describe "status" do
      it "should no be valid with random status" do
        order = Factory.build :order, :status => :randommmmmm
        order.should_not be_valid
        order.errors[:status].should_not be_nil
      end
    end
  end
  
  
  describe "status" do
    it "should be created with EMPTY status" do
      order = Factory.create :order, :status => nil
      order.status.should == Order::EMPTY
    end
    it "should be created with other than EMPTY status" do
      order = Factory.create :order, :status => Order::PROGRESS
      order.status.should == Order::PROGRESS
    end
    
    context "PROGRESS" do
      it "should update status to PROGRESS when the first photo is added" do
        order = Factory.create :order
        order.photos.create Factory.attributes_for :photo
        order.reload.status.should == Order::PROGRESS
      end
      it "should not update status to PROGRESS when the first photo is added and the status is not EMPTY" do
        order = Factory.create :order
        order.update_attribute :status, Order::READY
        order.photos.create Factory.attributes_for :photo
        order.reload.status.should == Order::READY
      end
      it "should update status to PROGRESS when the first image is added" do
        order = Factory.create :order
        order.images.create Factory.attributes_for :image
        order.reload.status.should == Order::PROGRESS
      end
    end
    
    context "CLOSED" do
      it "should update status to CLOSED when close is called" do
        order = Factory.create :order
        order.close
        order.status.should == Order::CLOSED
      end
    end
  end
  
  
end
