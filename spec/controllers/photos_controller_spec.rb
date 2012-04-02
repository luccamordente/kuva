require 'spec_helper'

describe PhotosController do

  describe "anonymous user" do
    specify { subject.current_user.should be_nil }
    
    it "should have a current_user" do
      get :index
      subject.current_user.should_not be_nil
    end
    
    it "should use the same user between subsequent requests" do
      get :index
      first_user_email = subject.current_user.email
      get :index
      first_user_email.should == subject.current_user.email
      pending "teste não está funcionando!"
    end
    
    it "should be anonymous" do
      get :index
      subject.current_user.should be_anonymous
    end
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
  
end