require 'spec_helper'

describe OrdersController do
  
  describe "close" do
    let!(:order){ Factory.create :order }
    
    it "should close an opened order" do
      post :close, :id => order.id
      order.reload.status.should == Order::CLOSED
    end
    
  end

end
