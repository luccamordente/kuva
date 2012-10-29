require 'spec_helper'

describe Api::OrdersController do

  before :each do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('pedrocinefoto', 'kuvaapi')
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'download'
      response.should be_success
    end
  end

  describe "GET 'closed'" do
    it "returns http success" do
      get 'closed'
      response.should be_success
    end
  end

end
