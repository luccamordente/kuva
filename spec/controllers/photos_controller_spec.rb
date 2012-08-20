require 'spec_helper'

describe PhotosController do
  
  describe "registered user" do
    login_user
    it "should not be anonymous" do
      subject.current_user.should_not be_anonymous
    end
  end
  
  
  describe "create" do
    login_user
    
    let!(:count){ 3 }
    let(:order){ Fabricate :order, user_id: current_user.id }
    let(:photo_attributes){ Fabricate.attributes_for(:photo, product_id: Fabricate(:product).id) }
    let(:specification_attributes){ Fabricate.attributes_for :specification, paper: 'glossy' }
    
    specify { order.user_id.should == current_user.id }
    
    # { 
    #   count: 10,
    #   photo: {
    #     count:      1,
    #     product_id: 12345678909876543,
    #     specs_attributes: { paper: :glossy }
    #   }
    # }
    context "successfully" do
      let(:product){ Fabricate :product }
      
      it "should respond with success and the photo ids" do
        post :create, order_id: order.id, photo: photo_attributes.merge(specification_attributes: specification_attributes), count: count
        response.should be_success
        ids = ActiveSupport::JSON.decode(response.body)['photo_ids']
        ids.compact.size.should == count
        order.reload
        photos = []
        expect { photos = ids.map{ |id| order.photos.find(id) } }.not_to raise_error
        photos.each do |photo| 
          photo.order.id.should == order.id 
          photo.specification.paper.should == 'glossy'
          photo.count.should == photo_attributes[:count]
        end
      end
      
      it "should keep only the count, spec and product_id" do
        post :create, order_id: order.id, photo: photo_attributes, count: count
        ids = ActiveSupport::JSON.decode(response.body)['photo_ids']
        order.reload
        photos = ids.map{ |id| order.photos.find id }
        photos.map(&:name).compact.should be_empty
      end
    end
    
    
    context "with validation error" do
      it "should respond unprocessable entity" do
        expect {
          post :create, order_id: order.id, photo: photo_attributes.except(:product_id), count: count
        }.not_to change(order.photos, :count)
        response.should_not be_success
        response.status.should == 422
        ActiveSupport::JSON.decode(response.body).should have_key "errors"
      end
    end
    
  end
  
  
  describe "update" do
    login_user
    
    let!(:paper){ Specification::PAPERS[0] }
    let!(:order){ Fabricate :order, user_id: current_user.id }
    let!(:product){ Fabricate :product }
    let!(:photo){ order.photos.create Fabricate.attributes_for(:photo).merge specification_attributes: Fabricate.attributes_for(:specification, paper: paper ), product_id: product.id }
    
    specify{ photo.image.should be_nil }
    specify { order.user_id.should == current_user.id }
    
    context "successfully" do
      it "should update the photo" do
        put :update, order_id: photo.order.id, id: photo.id, photo: { count: photo.count + 1 }
        response.should be_success
        (photo.count + 1).should == photo.reload.count
      end
      
      it "should update the photo nested attributes, like paper spec" do
        photo.specification.paper.should == paper
        put :update, order_id: photo.order.id, id: photo.id, photo: { specification_attributes: { paper: :glossy } }
        response.should be_success
        photo.reload.specification.paper.should_not be_nil
      end
      
      it "should update the image" do
        image = Fabricate :image
        put :update, order_id: photo.order.id, id: photo.id, photo: { image_id: image.id }
        response.should be_success
        photo.reload.image.should_not be_nil
      end
    end
    
  end
  
  
  
  
end