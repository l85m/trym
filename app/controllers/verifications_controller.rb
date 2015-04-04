class VerificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account_detail, only: [:new, :create]

  def new
  	@account_detail.send_confirmation_code
  end

  def create
  	if @account_detail.confirmed?( confirmation_code )

      if session[:referring_stop_order_id].present?
        stop_order_id = session[:referring_stop_order_id]
        session.delete(:referring_stop_order_id)
  		  redirect_to stop_order_manage_account_path stop_order_id: stop_order_id, id: "account_details"
      else
        
        if session[:text_alert]
          current_user.update( text_alert: true ) 
          session.delete(:text_alert)
        end
        
        if session[:text_summary]
          current_user.update( text_summary: true )
          session.delete(:text_summary)
        end
        
        redirect_to root_path
      end
  	
    else
      @errors = "confirmation code did not match - please try again"
  		render :new
  	end
  end

  private

    def set_account_detail
      @account_detail = current_user.account_detail
    end

	  def confirmation_code
	  	params.require(:account_detail).permit( :confirmation_code )[:confirmation_code]
	  end

end
