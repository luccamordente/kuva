require 'spec_helper'

describe Api::OrdersController do

  before :each do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('pedrocinefoto', 'kuvaapi')
  end

  describe "GET 'show'" do
    it "returns http success" do
      get :download, id: Fabricate(:order).close.id
      response.should be_success
    end
  end

  describe "GET 'closed'" do
    it "returns http success" do
      get 'closed', id: Fabricate(:order).id, format: :json
      response.should be_success
    end
  end

end
