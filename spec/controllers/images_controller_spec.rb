require 'spec_helper'

describe ImagesController do

  describe "create" do
    login_user
    
    let!(:order){ Fabricate :order, :user_id => current_user.id }
    
    context "with correct image" do
      it "should upload an image" do
        expect {
          post :create, :order_id => order.id, :image => { :image => fixture_file_upload(some_image_path, 'image/png') }
        }.to change(order.images, :count).by(1)
        response.should be_success
        expect { order.images.find(ActiveSupport::JSON.decode(response.body)['id']) }.not_to raise_error
      end
    end
    
    context "with no image" do
      it "should respond unprocessable entity" do
        expect {
          post :create, :order_id => order.id, :image => nil
        }.not_to change(order.images, :count).by(1)
        response.should_not be_success
        response.status.should == 422
        ActiveSupport::JSON.decode(response.body).should have_key "errors"
      end
    end
    
  end

end
