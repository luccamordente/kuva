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
        expect { order = Fabricate :order }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end

    context "open" do
      it "should notify the user" do
        order = Fabricate :order
        expect { order.update_status Order::CLOSED }.to change(ActionMailer::Base.deliveries, :count).by(1)
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
        image = Fabricate :image, order_id: order.id
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

    context "normal" do

      let!(:product){ Fabricate :product, name: "10x15" }
      let!(:order){ Fabricate :order }
      let!(:image){ order.images.create image: image_fixture('rgb.jpg') }
      let!(:zero_photo      ){ order.photos.create(count: 0, specification_attributes: { paper: Specification::MATTE_PAPER  },
                                product_id: product.id, image_id: image.id) }
      let!(:duplicated_photo){ order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  },
                                product_id: product.id, image_id: image.id)
                               order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  },
                                product_id: product.id, image_id: image.id)
                               order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  },
                                product_id: product.id, image_id: image.id)
                             }
      let!(:photos){[
        order.photos.create(count: 5, specification_attributes: { paper: Specification::GLOSSY_PAPER }, product_id: product.id, image_id: image.id),
        duplicated_photo,
        duplicated_photo,
        zero_photo
      ]}

      subject{ order.compressed }

      after do
        system "rm -f #{order.tmp_zip_path}"
        system "rm -rf /tmp/#{order.tmp_identifier}"
        Dir.chdir Rails.root # pro rspec não ficar locao
      end


      it         { should_not be_nil          }
      its(:class){ should == File             }
      its(:path) { should match /tmp.*?\.zip/ }

      it "should delete the original dir" do
        expect{ Dir.new order.tmp_path }.to raise_error Errno::ENOENT
      end

      it "should delete the zip file" do
        expect{ Dir.new order.tmp_zip_path }.to raise_error Errno::ENOENT
      end


      context "decompressed" do
        before do
          Dir.chdir Order.tmp_path
          system "unzip #{subject.path} -d /tmp > /dev/null"
          Dir.chdir "/tmp/#{order.tmp_identifier}"
        end

        after do
          system "rm -f #{order.tmp_zip_path}"
          system "rm -rf /tmp/#{order.tmp_identifier}"
          Dir.chdir Rails.root # pro rspec não ficar locao
        end

        it "should contain 2 dirs" do
          Dir["*"].count.should == 2
        end

        it "should include photos with image" do
          photos.each do |photo|
            photo_dir = photo.directory.name
            Dir["#{photo_dir}/*"].should include File.join(photo_dir, File.basename(photo.reload.image.image.current_path)) if photo.count > 0
          end
        end

        it "should create no dir when photo count = 0" do
          Dir["#{zero_photo.directory.name}/*"].should_not include zero_photo.directory.name
        end

        it "should copy files duplicated images" do
          files = Dir["#{duplicated_photo.directory.name}/*"]
          files.count.should == 3
          files[0].should match /rgb.jpg$/
          files[1].should match /rgb\[1\].jpg$/
          files[2].should match /rgb\[2\].jpg$/
        end

      end
    end



    context "with originals" do
      let!(:product){ Fabricate :product, name: "10x15" }
      let!(:order){ Fabricate :order }
      let!( :rgb_image){ order.images.create image: image_fixture( 'rgb.jpg') }
      let!(:cmyk_image){ order.images.create image: image_fixture('cmyk.jpg') }
      let!(:photos){[
        order.photos.create(count: 5, specification_attributes: { paper: Specification::GLOSSY_PAPER }, product_id: product.id, image_id:  rgb_image.id),
        order.photos.create(count: 2, specification_attributes: { paper: Specification::MATTE_PAPER  }, product_id: product.id, image_id: cmyk_image.id)
      ]}
      subject{ order.compressed originals: true }

      after do
        system "rm -f #{order.tmp_zip_path}"
        system "rm -rf /tmp/#{order.tmp_identifier}"
        Dir.chdir Rails.root # pro rspec não ficar locao
      end

      it "should include the original images when stored" do
        Dir.chdir Order.tmp_path
        system "unzip #{subject.path} -d /tmp > /dev/null"
        Dir.chdir "/tmp/#{order.tmp_identifier}"
        photos.each do |photo|
          image    = photo.reload.image.image
          original = image.original
          if image.original.present?
            Dir["#{photo.directory.name}/*"].should     include(File.join(photo.directory.name, File.basename(original.current_path)))
            Dir["#{photo.directory.name}/*"].should_not include(File.join(photo.directory.name, File.basename(   image.current_path)))
          else
            Dir["#{photo.directory.name}/*"].should     include(File.join(photo.directory.name, File.basename(   image.current_path)))
            Dir["#{photo.directory.name}/*"].should_not include(File.join(photo.directory.name, File.basename(original.current_path)))
          end
        end
      end

    end




    context "compression error" do
      let!(:product){ Fabricate :product, name: "10x15" }
      let!(:order){ Fabricate :order }
      let!(:image){ order.images.create image: image_fixture('rgb.jpg') }
      let!(:photos){[
        # with no image_id to force error
        order.photos.create(count: 5, specification_attributes: { paper: Specification::GLOSSY_PAPER }, product_id: product.id, image_id: nil)
      ]}

      it "should delete the original temporary dir when anything wrong happen in between" do
        expect{ order.compressed }.to raise_error
        expect{ Dir.new order.tmp_path }.to raise_error Errno::ENOENT
      end
    end


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