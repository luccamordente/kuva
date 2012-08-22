class SessionsController < Devise::SessionsController
  skip_before_filter :require_no_authentication, only: [:new]
  before_filter :require_no_authentication, only: [:new], unless: :current_anonymous_user?
  
  before_filter :determine_anonymous_user_with_valid_login, only: :create, if: :current_anonymous_user?
  after_filter :move_anonymous_user, only: :create
  
  
  private
    
    def determine_anonymous_user_with_valid_login
      user = User.where(email: params[:user][:email]).first
      if user.valid_password? params[:user][:password]
        @anonymous_user = current_user
        sign_out @anonymous_user
        @anonymous_user_valid_login = true
      end
    end
    
    def move_anonymous_user
      if @anonymous_user_valid_login
        @anonymous_user.move_to current_user
      end
    end
    
    def current_anonymous_user?
      user_signed_in? && current_user.anonymous?
    end
end