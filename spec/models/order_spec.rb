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
        order = Fabricate :order
        order.send "#{attr}=", nil
        order.should_not be_valid
        order.errors[attr].should_not be_nil
      end
    end
    
    describe "status" do
      it "should no be valid with random status" do
        order = Fabricate.build :order, :status => :randommmmmm
        order.should_not be_valid
        order.errors[:status].should_not be_nil
      end
    end
  end
  
  
  describe "notifications" do
    
    context "open" do
      it "should notify the staff" do
        expect { order = Fabricate :order }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
    
    context "open" do
      it "should notify the staff" do
        order = Fabricate :order
        expect { order.update_status Order::CLOSED }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
    
  end
  
  
  describe "status" do
    it "should be created with EMPTY status" do
      order = Fabricate :order, :status => nil
      order.status.should == Order::EMPTY
    end
    it "should be created with other than EMPTY status" do
      order = Fabricate :order, :status => Order::PROGRESS
      order.status.should == Order::PROGRESS
    end
    
    context "PROGRESS" do
      it "should update status to PROGRESS when the first photo is added" do
        order = Fabricate :order
        photo = order.photos.create Fabricate.attributes_for :photo
        photo.should be_persisted
        order.reload.status.should == Order::PROGRESS
      end
      it "should not update status to PROGRESS when the first photo is added and the status is not EMPTY" do
        order = Fabricate :order
        order.update_attribute :status, Order::READY
        order.photos.create Fabricate.attributes_for :photo
        order.reload.status.should == Order::READY
      end
      it "should update status to PROGRESS when the first image is added" do
        order = Fabricate :order
        image = order.images.create Fabricate.attributes_for :image
        image.should be_persisted
        order.reload.status.should == Order::PROGRESS
      end
    end
    
    
    context "update" do
      Order::STATUSES.each do |status|
        
        context "status to #{status}" do
          subject{ Fabricate :order }
        
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
  
  
  
  describe "compress" do
      
    let!(:product){ Fabricate :product, :name => "10x15" }
    let!(:order){ Fabricate :order }
    let!(:image){ order.images.create :image => image_fixture }
    let!(:photos){[ 
      order.photos.create(:count => 5, :specification_attributes => { :paper => Specification::GLOSSY_PAPER }, :product_id => product.id, :image_id => image.id),
      order.photos.create(:count => 2, :specification_attributes => { :paper => Specification::MATTE_PAPER  }, :product_id => product.id, :image_id => image.id),
      order.photos.create(:count => 2, :specification_attributes => { :paper => Specification::MATTE_PAPER  }, :product_id => product.id, :image_id => image.id)
    ]}
    
    subject{ order.compressed }
    after{ system "rm -rf #{ order.tmp_zip_path }"}
    
    it { should_not be_nil }
    its(:class){ should == File }
    its(:path) { should match /tmp.*?\.zip/ }
    
    it "should delete the original dir" do
      subject
      expect{ Dir.new order.tmp_path }.to raise_error Errno::ENOENT
    end
    
    it "should contain 2 dirs" do
      Dir.chdir Order.tmp_path
      system "unzip #{subject.path} -d . > /dev/null"
      Dir.chdir order.tmp_path
      dirs = Dir["*"]
      dirs.count.should == 2
      photos.each do |photo|
        Dir["#{photo.directory.name}/*"].should include(File.join(photo.directory.name, photo.reload.image.image.current_path.split(/\//).last))
      end
      system "rm -r #{order.tmp_path}"
    end
    
    
  end


  
end
