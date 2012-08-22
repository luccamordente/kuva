class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def success response
    render json: response
  end

  def error status, errors
    options = { status: :unprocessable_entity, json: { errors: errors } }
    options = options.merge status: status if status

    render options
  end
  
private

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User) 
        if resource.orders.count == 0
          new_order_path
        else
          orders_path
        end
      else
        super
      end
  end

end
