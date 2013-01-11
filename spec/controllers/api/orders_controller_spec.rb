require 'spec_helper'

describe Api::OrdersController do

  before :each do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('pedrocinefoto', 'kuvaapi')
  end

  describe "GET 'show'" do
    context "failure" do
      it "returns http forbidden for not closed orders" do
        order = Fabricate(:order)
        get :download, id: order.id
        response.status.should == 410
      end
    end

    context "success " do
      it "returns http success for closed orders" do
        get :download, id: Fabricate(:order).close.id
        response.should be_success
      end
      it "returns http success for orders to recatch" do
        order = Fabricate(:order).close
        order.update_status Order::RECATCH
        get :download, id: order.id
        response.should be_success
      end
    end

  end

  describe "GET 'closed'" do
    it "returns http success" do
      get :closed, format: :json
      response.should be_success
    end

    it "returns only closed or orders marked to recatch"
  end

end
