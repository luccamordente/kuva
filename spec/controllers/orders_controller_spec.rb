require 'spec_helper'

describe OrdersController do
  
  login_user
  
  describe "open" do
    it "opens a new order" do
      get :open
      order = assigns[:order]
      order.should_not be_nil
      order.should be_persisted
      order.user_id.should == current_user.id
    end
    
    it "creates a new order for current user each time" do
      expect { 2.times { get :open } }.to change(current_user.orders, :count).by 2
    end
    
    it "loads photos specs" do
      get :open
      specs = assigns[:specs]
      specs[:paper].should_not be_nil
      Spec::PAPERS.each { |paper| specs[:paper][paper].should == I18n.t("photo.specs.paper.#{paper}") }
    end
    
    it "loads the products" do
      get :open
      assigns[:products].should_not be_nil
    end
  end
  
  
  describe "close" do
    let!(:order){ Factory.create :order, :user_id => current_user.id }
    
    specify { order.user_id.should == current_user.id }
    
    it "closes an opened order" do
      post :close, :id => order.id
      order.reload.status.should == Order::CLOSED
    end
    
  end

end
