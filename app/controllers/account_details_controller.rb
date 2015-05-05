class AccountDetailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account_detail, only: [:new, :create, :edit, :update, :destroy]

  def new
  	@account_detail ||= AccountDetail.new
    if params[:enable_text_alert] || params[:enable_text_summary]
      session.delete(:referring_stop_order_id)
      
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
		if account_detail_params[:temp_phone].present? && @account_detail.save
			redirect_to controller: "verifications", action: "new"
		else
			render "error"
		end
  end

  def turn_off_intro
    #TODO: quick and dirty - we should change this
    current_user.update(show_intro: false)
    head :ok, content_type: "text/html"
  end

  def turn_on_intro
    #TODO: quick and dirty - we should change this
    current_user.update(show_intro: true)
    redirect_to root_path
  end

  def edit
    @account_detail ||= AccountDetail.new( user_id: current_user.id )
    if params[:referring_stop_order_id]
      session[:referring_stop_order_id] = params[:referring_stop_order_id]
    end
  end

  def update
    @account_detail ||= AccountDetail.new( user_id: current_user.id )
		if account_detail_params[:temp_phone].present? && @account_detail.update( account_detail_params )
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
      params.require(:account_detail).permit( :first_name, :last_name, :temp_phone )
    end
end