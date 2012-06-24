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
        photo = order.photos.create Factory.attributes_for :photo
        photo.should be_persisted
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
        image = order.images.create Factory.attributes_for :image
        image.should be_persisted
        order.reload.status.should == Order::PROGRESS
      end
    end
    
    
    context "update" do
      Order::STATUSES.each do |status|
        
        context "status to #{status}" do
          subject{ Factory.create :order }
        
          specify{ subject.status.should == Order::EMPTY }
          specify{ subject.send(:"#{status}_at").should be_nil }
        
          context do
            before(:all) { subject.update_status status }
        
            its(:status){ should == status}
            its(:"#{status}_at"){ should_not be_nil }            
          end
        end
        
      end  
    end
    
    
  end
  
  describe "downloadable" do
    it "should not be downloadable when empty    "
    it "should not be downloadable when progress "
    it "should be downloadable when closed   "
    it "should be downloadable when catching "
    it "should be downloadable when caught   "
    it "should be downloadable when ready    "
    it "should be downloadable when delivered"
  end
  
  
end
