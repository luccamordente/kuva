require 'spec_helper'

describe Order do
  extend OrderMacros

  describe "relationships" do
    it { should belong_to  :user   }
    it { should embed_many :photos }
    it { should have_many(:images) }
  end

  describe "validation" do
    validate_timestamps

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
        order = Fabricate.build :order, status: :randommmmmm
        order.should_not be_valid
        order.errors[:status].should_not be_nil
      end
    end
  end


  describe "notifications" do

    context "open" do
      it "should notify the staff" do
        pending "Send asynchronously"
        expect { order = Fabricate :order }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

    context "open" do
      it "should notify the staff and the user" do
        order = Fabricate :order
        expect { order.update_status Order::CLOSED }.to change(ActionMailer::Base.deliveries, :count).by(2)
      end
    end

  end


  describe "status" do
    it "should be created with EMPTY status" do
      order = Fabricate :order, status: nil
      order.status.should == Order::EMPTY
    end
    it "should be created with other than EMPTY status" do
      order = Fabricate :order, status: Order::PROGRESS
      order.status.should == Order::PROGRESS
    end

    context "PROGRESS" do
      let(:product){ Fabricate :product }
      it "should update status to PROGRESS when the first photo is added" do
        order = Fabricate :order
        photo = order.photos.create Fabricate.attributes_for(:photo).merge(product_id: product.id)
        photo.should be_persisted
        order.reload.status.should == Order::PROGRESS
      end
      it "should not update status to PROGRESS when the first photo is added and the status is not EMPTY" do
        order = Fabricate :order
        order.update_attribute :status, Order::READY
        photo = order.photos.create Fabricate.attributes_for(:photo).merge(product_id: product.id)
        photo.should be_persisted
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


    describe "promise" do
      subject { Fabricate :order }
      let!(:closed_at) { subject.closed_at }

      before(:all) { subject.update_status Order::CLOSED }

      its(:promised_for) { should == closed_at + 1.hour }
    end


    describe "sent" do
      orders_with_each_status %W{ CLOSED CATCHING CAUGHT } do |order, status|
        it "should be sent when status is #{status}" do
          order.should be_sent
        end
      end
    end

  end



  describe "executable" do
    orders_with_each_status %W{ EMPTY PROGRESS CLOSED CATCHING READY DELIVERED CANCELED } do |order, status|
      it "should not be executable when #{status}" do
        order.should_not be_executable
      end
    end

    orders_with_each_status %W{ CAUGHT } do |order, status|
      it "should be executable when #{status}" do
        order.should be_executable
      end
    end
  end


  describe "deliverable" do
    orders_with_each_status %W{ EMPTY PROGRESS CLOSED CATCHING CAUGHT DELIVERED CANCELED } do |order, status|
      it "should not be deliverable when #{status}" do
        order.should_not be_deliverable
      end
    end

    orders_with_each_status %W{ READY } do |order, status|
      it "should be deliverable when #{status}" do
        order.should be_deliverable
      end
    end
  end


  describe "downloadable" do
    orders_with_each_status %W{ EMPTY PROGRESS CANCELED } do |order, status|
      it "should not be downloadable when #{status}" do
        order.should_not be_downloadable
      end
    end

    orders_with_each_status %W{ CLOSED CATCHING CAUGHT READY DELIVERED } do |order, status|
      it "should be downloadable when #{status}" do
        order.should be_downloadable
      end
    end
  end


  describe "downloaded" do
    orders_with_each_status %W{ EMPTY PROGRESS CLOSED } do |order, status|
      it "should not be downloaded when #{status}" do
        order.should_not be_downloaded
      end
    end

    orders_with_each_status %W{ CATCHING CAUGHT READY DELIVERED } do |order, status|
      it "should be downloaded when #{status}" do
        order.should be_downloaded
      end
    end
  end

  describe "canceled" do
    orders_with_each_status %W{ CANCELED } do |order, status|
      it "should be canceled when status is #{status}" do
        order.should be_canceled
      end
      it "should be canceled if canceled at any time" do
        order.update_status Order::READY
        order.should be_canceled
      end
    end
  end



  describe "compress" do

    let!(:product){ Fabricate :product, name: "10x15" }
    let!(:order){ Fabricate :order }
    let!(:image){ order.images.create image: image_fixture }
    let!(:photos){[
      order.photos.create(count: 5, specification_attributes: { paper: Specification::GLOSSY_PAPER }, product_id: product.id, image_id: image.id),
      order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  }, product_id: product.id, image_id: image.id),
      order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  }, product_id: product.id, image_id: image.id),
      # photo without image that cannot fail
      order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  }, product_id: product.id)
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

    it "should delete zip file"

    it "should contain 2 dirs and include photos with image" do
      Dir.chdir Order.tmp_path
      system "unzip #{subject.path} -d . > /dev/null"
      Dir.chdir order.tmp_path
      dirs = Dir["*"]
      dirs.count.should == 2
      photos.each do |photo|
        image = photo.reload.image
        next if image.nil?
        Dir["#{photo.directory.name}/*"].should include(File.join(photo.directory.name, image.image.current_path.split(/\//).last))
      end
      system "rm -r #{order.tmp_path}"
    end

    it "should delete the original dir when anything wrong happens in between"
    it "allows photos without image, by simply not copying the image"


  end



  describe "price" do
    let!(:order)   { Fabricate :order }
    let (:product1){ Fabricate :product, price: 1 }
    let (:product2){ Fabricate :product, price: 2 }
    let (:product3){ Fabricate :product, price: 3 }

    specify{ order.price.should == 0 }

    it "should increase order price when a photo is added" do
      count   = 2
      expect {
        order.photos.create product_id: product1.id, count: count
      }.to change(order, :price).by product1.price * count
    end

    it "should increase order price when a second photo is added" do
      count   = 2
      order.photos.create product_id: product1.id, count: count
      expect {
        order.photos.create product_id: product2.id, count: count
      }.to change(order, :price).by product2.price * count
    end

    it "should increase order price when the count of a photo is increased" do
      count   = 2
      photo   = order.photos.create product_id: product2.id, count: 1
      expect {
        photo.update_attribute :count, count
      }.to change(order, :price).by product2.price * 1
    end

    it "should decrease order price when the count of a photo is decrease" do
      count   = 2
      photo   = order.photos.create product_id: product3.id, count: 3
      expect {
        photo.update_attribute :count, count
      }.to change(order, :price).by product3.price * -1
    end

    it "should decrese order price when a photo is destroyed" do
      count   = 15
      photo   = order.photos.create product_id: product2.id, count: count
      expect {
        photo.destroy
      }.to change(order, :price).by product2.price * -count
    end

  end


  describe "destroy" do
    let!(:order){ Fabricate :order }
    let!(:image){ order.images.create image: image_fixture }

    it "should delete associated images when order is destroyed" do
      order.destroy
      expect{ image.reload }.to raise_error
    end
  end


end