class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || charges_path
  end

  def access_denied(args)
  	redirect_to root_path, flash: {error: "You don't have permission to do that"}
  end

	def not_found
	  raise ActionController::RoutingError.new('Not Found')
	end

end