class VerificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account_detail, only: [:new, :create]

  def new
  	@account_detail.send_confirmation_code
  end

  def create
  	unless @account_detail.confirmed?( confirmation_code )
  		render "error"
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
