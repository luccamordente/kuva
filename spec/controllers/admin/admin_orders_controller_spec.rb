require 'spec_helper'

describe Admin::OrdersController do
  
  
  describe "download closed order" do
    
    let!(:order) do 
      order = Fabricate :order do |order|
        image = Fabricate :image, image: image_fixture
        images { [ image ] }
      end
      product = Fabricate :product
      order.photos.create count: 5, specification_attributes: { paper: Specification::GLOSSY_PAPER },
       product_id: product.id, image_id: order.images.first.id
      order.photos.create count: 3, specification_attributes: { paper: Specification::MATTE_PAPER  },
       product_id: product.id, image_id: order.images.first.id
      order.update_status :closed
      order
    end
    
    specify{ order.status.should == Order::CLOSED }
    
    it "changes the order status to caught" do
      controller.stub!(:render)
      controller.should_receive :send_data
      get :download, id: order.id
      order.reload.status.should == Order::CAUGHT
    end
      
  end
  
  
  describe "download caught order" do
    it "does not change order status"
  end
  
  
end
