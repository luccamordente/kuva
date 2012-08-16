module LoginMacros
  
  def login_admin
    before :each do
      admin = Fabricate(:admin)
      visit new_admin_session_path
      fill_in 'admin_email',    :with => admin.email
      fill_in 'admin_password', :with => admin.password
      click_button 'Sign in'
      @current_admin = admin
    end
  end
  
  def login_user
    before :each do
      LoginHelpers.login_user_now
    end
  end
end

module LoginHelpers
  
  def login_user_now &block
    user = Fabricate(:user)
    visit new_user_session_path
    fill_in 'user_email',    :with => user.email
    fill_in 'user_password', :with => user.password
    yield user if block_given?
    click_button 'Sign in'
    @current_user = user
  end
  
end