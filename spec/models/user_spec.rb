require 'spec_helper'

describe User do
  
  
  describe "validations" do
    validate_timestamps
    it{ should validate_presence_of(:name) }
  end
  
  describe "relationships" do
    it { should have_many(:orders).with_foreign_key(:user_id) }
    it "destroy orders when destroyed" do
      user  = Fabricate :user
      order = Fabricate :order, :user_id => user.id
      user.destroy
      expect{ order.reload }.to raise_error
    end
  end
  
  describe "fields" do
    it { should have_field(:anonymous).of_type(Boolean).with_default_value_of(false) }
  end
  
  describe "move to" do
    
    describe "anonymous user" do
      let!(:anonymous_user){ Fabricate :user, :anonymous => true }
      let!(:anonymous_order){ Fabricate :order, :user_id => anonymous_user.id }
      let!(:registered_user){ Fabricate :user }
      let!(:registered_order){ Fabricate :order, :user_id => registered_user.id }
      before do
        anonymous_user.move_to registered_user
      end
      it "destroys the original user" do
        expect { anonymous_user.reload }.to raise_error
      end
      it "moves the orders to the other user" do
        registered_user.reload
        registered_user.orders.should_not be_empty
      end
      it "should not override the user orders" do
        registered_user.orders.sort.should == [registered_order, anonymous_order].sort
      end
    end
    
    describe "registered user" do
      it "should no allow registered user to be moved" do
        expect{ Fabricate(:user).move_to Fabricate(:user) }.to raise_error
      end
    end
    
  end
  
  
  describe "authentication token" do
    subject{ Fabricate :user }
    its(:authentication_token){ should_not be_nil }
    
    it "better change the authentication token at some point... it's not secure to keep the same token forever!"
  end
  
  
  
  describe "creation" do
    subject{ Fabricate.build :user }
    
    describe "before" do
      its(:reset_password_token){ should be_nil }
    end
    
    describe "after" do
      before do
        subject.save
      end
    
      its(:reset_password_token){ should_not be_nil }
    end
  end
  
  
  describe "welcome email with password instructions" do
    let!(:user){ Fabricate :user }
    
    it "should send email" do
      expect { user.send :send_welcome_mail_with_password_instructions }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
  
  
end
