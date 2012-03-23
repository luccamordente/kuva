module LoginMacros
  def login_admin
    before :each do
      admin = Factory.create(:admin)
      visit new_admin_session_path
      fill_in 'admin_email',    :with => admin.email
      fill_in 'admin_password', :with => admin.password
      click_button 'Sign in'
      @current_admin = admin
    end
  end
  
  def login_user
    before :each do
      user = Factory.create(:user)
      visit new_user_session_path
      fill_in 'user_email',    :with => user.email
      fill_in 'user_password', :with => user.password
      click_button 'Sign in'
      @current_user = user
    end
  end
end