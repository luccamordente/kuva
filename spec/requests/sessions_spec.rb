require 'spec_helper'

describe "Sessions" do
  
  describe "sign in" do
    context "with no orders" do
      it "takes the user to a new order" do
        login_user_now
        page.current_path.should == new_order_path
      end
    end
    
    context "with at least one order" do
      it " takes the user to orders list" do
        login_user_now do |user|
          user.orders << Fabricate(:order)
        end
        page.current_path.should == orders_path
      end
    end
  end
  
end
