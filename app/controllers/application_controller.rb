class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # before_filter :down_for_maitenance
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

  private

  def show_location_restriction
    unless current_user
      loc = GeoIP.new(Rails.root.join("GeoLiteCity.dat")).city(request.remote_ip)
      if loc && loc.country_code2 != "US"
        flash[:notice] = "You appear to be visiting from a location outside of the US.  Please note that currently trym can only support linking and managing accounts that are based in the US."
      end
    end
  end
  
  def down_for_maitenance
    unless current_user && current_user.admin?
      redirect_to upgrades_path if request.path != '/upgrades'
    end
  end

end