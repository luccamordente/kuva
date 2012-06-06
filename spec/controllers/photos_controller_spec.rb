require 'spec_helper'

describe PhotosController do

  describe "anonymous user" do
    specify { subject.current_user.should be_nil }
    
    it "should not have a current_user" do
      get :index
      subject.current_user.should be_nil
    end
    
    # it "should have a current_user" do
    #   get :index
    #   subject.current_user.should_not be_nil
    # end
    # 
    # it "should use the same user between subsequent requests" do
    #   get :index
    #   first_user_email = subject.current_user.email
    #   get :index
    #   first_user_email.should == subject.current_user.email
    #   pending "teste não está funcionando!"
    # end
    # 
    # it "should be anonymous" do
    #   get :index
    #   subject.current_user.should be_anonymous
    # end
  end
  
  describe "registered user" do
    login_user
    it "should not be anonymous" do
      subject.current_user.should_not be_anonymous
    end
  end
  
  
  
  describe "start" do
    login_user
    it "creates a new order for current user each time" do
      expect { 2.times { get :index } }.to change(subject.current_user.orders, :count).by 2
    end
  end
  
  
  describe "create" do
    
    let(:count){ 3 }
    let(:order){ Factory.create :order }
    let(:photo_attributes){ Factory.attributes_for(:photo) }
    
    # { 
    #   :count => 10,
    #   :photo => {
    #     :count      => 1,
    #     :product_id => 12345678909876543,
    #     :specs_attributes => { :paper => :glossy }
    #   }
    # }
    context "successfully" do
      context do
        login_user
        it "should respond with success and the photo ids" do
          post :create, :order_id => order.id, :photo => photo_attributes.merge(:spec_attributes => {:paper => "asd"}), :count => count
          response.should be_success
          ids = ActiveSupport::JSON.decode(response.body)['photo_ids']
          ids.compact.size.should == count
          order.reload
          photos = []
          expect { photos = ids.map{ |id| order.photos.find(id) } }.not_to raise_error
          photos.each { |photo| 
            photo.order.id.should == order.id 
            photo.spec.paper.should == "asd"
            photo.count.should == photo_attributes[:count]
          }
        end        
      end
      context do
        login_user
        it "should keep only the count, spec and product_id" do
          post :create, :order_id => order.id, :photo => photo_attributes, :count => count
          ids = ActiveSupport::JSON.decode(response.body)['photo_ids']
          order.reload
          photos = ids.map{ |id| order.photos.find id }
          photos.map(&:name).compact.should be_empty
        end
      end
    end
    
  end
  
  
  describe "update" do
    
    let!(:order){ Factory.create :order }
    let!(:photo){ order.photos.create Factory.attributes_for(:photo).merge :spec_attributes => { :paper => nil } }
    
    context "successfully" do
      context do
        login_user
        it "should update the photo" do
          put :update, :order_id => photo.order.id, :id => photo.id, :photo => { :count => photo.count + 1 }
          photo.should be_valid
          response.should be_success
          (photo.count + 1).should == photo.reload.count
        end
      end
      
      context do
        login_user
        it "should update the photo nested attributes, like paper spec" do
          photo.spec.paper.should be_nil
          put :update, :order_id => photo.order.id, :id => photo.id, :photo => { :spec_attributes => { :paper => :glossy } }
          photo.should be_valid
          response.should be_success
          photo.reload.spec.paper.should_not be_nil
        end
      end
      
      context do
        login_user
        it "should upload an image" do
          pending "Upload tem que ser feito desacoplado da Photo e depois associado a ela!"
          put :update, :order_id => photo.order.id, :id => photo.id, 
            :photo => { :image_attributes => { :image => fixture_file_upload(File.join(Rails.root,"app/assets/images/rails.png"), 'image/png') } }
          photo.should be_valid
          response.should be_success
          photo.reload.image.should_not be_nil
        end
      end
    end
    
  end
  
  
  
  
end