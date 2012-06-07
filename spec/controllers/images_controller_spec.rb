require 'spec_helper'

describe ImagesController do

  describe "create" do
    login_user
    
    let!(:order){ Factory.create :order }
    
    it "should upload an image" do
      expect {
        post :create, :order_id => order.id, :image => { :image => fixture_file_upload(File.join(Rails.root,"app/assets/images/rails.png"), 'image/png') }
      }.to change(order.images, :count).by(1)
      response.should be_success
      expect { order.images.find(ActiveSupport::JSON.decode(response.body)['id']) }.not_to raise_error
    end
  end

end
