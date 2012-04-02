require 'spec_helper'

describe User do
  
  validate_timestamps
  
  describe "relationships" do
    it { should have_many(:orders).with_foreign_key(:user_id) }
    it "destroy orders when destroyed" do
      user  = Factory.create :user
      order = Factory.create :order, :user_id => user.id
      user.destroy
      expect{ order.reload }.to raise_error
    end
  end
  
  describe "fields" do
    it { should have_field(:anonymous).of_type(Boolean).with_default_value_of(false) }
  end
  
  describe "move to" do
    
    describe "anonymous user" do
      let!(:user){ Factory.create :user, :anonymous => true }
      let!(:another_user){ Factory.create :user }
      let!(:order){ Factory.create :order, :user_id => user.id }
      before do
        user.move_to another_user
      end
      it "destroys the original user" do
        expect { user.reload }.to raise_error
      end
      it "moves the orders to the other user" do
        another_user.reload
        another_user.orders.should_not be_empty
        another_user.orders.should == [order]
      end
    end
    
    describe "registered user" do
      it "should no allow registered user to be moved" do
        expect{ Factory.create(:user).move_to Factory.create(:user) }.to raise_error
      end
    end
    
  end
  
  
end
