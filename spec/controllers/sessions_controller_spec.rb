require 'spec_helper'

describe SessionsController do

  describe "GET /new" do
    describe "registered user" do
      before do
        request.env["HTTP_REFERER"] = "where_i_came_from"
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in Fabricate :user, anonymous: false
      end
      it "should be redirected" do
        get :new
        response.should be_redirect
      end
    end
    
    describe "anonymous user" do
      before do
        request.env["HTTP_REFERER"] = "where_i_came_from"
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in Fabricate :user, anonymous: true
      end
      it "should not be redirected" do
        get :new
        response.should_not be_redirect
      end
    end
  end
  
  describe "POST /create" do
    describe "anonymous user" do
      let!(:anonymous_user){ Fabricate :user, anonymous: true }
      let!(:registered_user){ Fabricate :user, anonymous: true, password: "123456", password_confirmation: "123456" }
      before do
        request.env["HTTP_REFERER"] = "where_i_came_from"
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in anonymous_user
      end
      context "with correct password" do
        before do
          post :create, user: { email: registered_user.email, password: registered_user.password }
        end
        it "should sign out the anonymous user" do
          subject.current_user.email.should_not == anonymous_user.email
        end
        it "should sign in the registered user" do
          subject.current_user.email.should == registered_user.email
        end
        it "should move the anonymous user to registered user" do
          expect{ anonymous_user.reload }.to raise_error
        end
      end
      context "with incorrect password" do
        before do
          post :create, user: { email: registered_user.email, password: "IncorrectPassword" }
        end
        it "should not sign out the anonymous user" do
          subject.current_user.email.should == anonymous_user.email
        end
        it "should not sign in the registered user" do
          subject.current_user.email.should_not == registered_user.email
        end
        it "should not move the anonymous user to registered user" do
          expect{ anonymous_user.reload }.not_to raise_error
        end
      end
      
    end
  end
  
end