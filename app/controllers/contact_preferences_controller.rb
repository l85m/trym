class ContactPreferencesController < ApplicationController
  before_action :authenticate_user!
	respond_to :js

	def update
		current_user.update( contact_preferences_params )
		render nothing: true
	end

	private

	def contact_preferences_params
		params.permit(:email_alert, :email_summary, :text_alert, :text_summary)
	end
	
end



