module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin) # Using factory girl as an example
    end
  end

  def login_user
    let (:current_user) {@user = Factory.create(:user)}
    
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      
      if (controller) 
        @request.env["warden"].stub :authenticate!
        controller.stub(:current_user).and_return current_user
      end
      
      sign_in current_user
    end
  end
end