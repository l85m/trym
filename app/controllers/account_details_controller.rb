class AccountDetailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account_detail, only: [:new, :edit, :update, :destroy]

  def new
  	@account_detail ||= AccountDetail.new
    if params[:enable_text_alert] || params[:enable_text_summary]
      session.delete(:referring_charge_id) 
      if params[:enable_text_alert] 
        session[:text_alert] = true
      else
        session[:text_summary] = true
      end
    end
  end

  def create
  	@account_detail ||= AccountDetail.new( user_id: current_user.id )
  	@account_detail.assign_attributes account_detail_params
		if @account_detail.save
			redirect_to controller: "verifications", action: "new"
		else
			render "error"
		end
  end

  def edit
  end

  def update
		if @account_detail.update( account_detail_params )
			redirect_to controller: "verifications", action: "new"
		else
			render "error"
		end
  end

  def destroy
  end

  private

    def set_account_detail
      @account_detail = current_user.account_detail
    end

    def account_detail_params
      params.require(:account_detail).permit( :first_name, :last_name, :phone )
    end
end