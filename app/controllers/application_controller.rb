class ApplicationController < ActionController::Base
  protect_from_forgery
  
  protected
  
  def success response
    render :json => response
  end
  
  def error status, errors
    options = { :status => :unprocessable_entity, :json => { :errors => errors } }
    options = options.merge :status => status if status
    
    render options
  end
  
end
