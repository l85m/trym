class LinkedAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_linked_account, only: [:show, :edit, :update, :destroy]
  after_action :set_new_transaction_false_on_charges, only: :show
  respond_to :html, :js, :json

  def show
    if params[:grouping].present?
      @grouping = params[:grouping].downcase.gsub(" ", "_").strip
      if ["very_likely", "likely", "unlikely", "very_unlikely"].include?(@grouping)
        charges = Charge.where(linked_account: @linked_account).send("recurring_#{@grouping}") 
        @stop_order_charge_ids = charges.includes(:stop_orders).pluck('stop_orders.id')
        @charges = charges.with_merchant.sort_by_recurring_score.sort_by_new_first
        @grouping = @grouping.gsub("_","-")
      end
    
    else
      charges = @linked_account.charges
    
      @stop_order_charge_ids = charges.includes(:stop_orders).pluck('stop_orders.id')
      @charges = charges.with_merchant.sort_by_recurring_score.sort_by_new_first.group_by(&:recurring_score_grouping)
      
      respond_with(@linked_account)
    end
  end

  def index
    @linked_accounts = current_user.linked_accounts.has_data.order(created_at: :desc)
  end

  def new
    @linked_account = LinkedAccount.new
    respond_with(@linked_account)
  end

  def create
    @linked_account = LinkedAccount.find_or_create_by(linked_account_params)
    unless @linked_account.present?
      render 'error'
    else
      @linked_account.update( last_api_response: nil )
      AccountLinker.perform_async( account_linker_params, @linked_account.id )
    end
  end

  def edit
  end

  def update
    #TODO: Handle Reauth / Account Destroy
    if @linked_account.last_api_response["response_code"] == "201"
      @linked_account.update( last_api_response: nil )
      AccountLinker.perform_async( mfa_params, @linked_account.id )
    end
  end

  def destroy
    @linked_account.delink
    redirect_to root_path
  end

  private
    def set_linked_account
      @linked_account = LinkedAccount.find(params[:id])
    end

    def linked_account_params
      params.require(:linked_account).permit(:financial_institution_id).merge({ user_id: current_user.id })
    end

    def account_linker_params
      params.require(:linked_account).permit(:username, :password, :pin)
    end

    def mfa_params
      params.require(:linked_account).permit(:mfa_response)
    end

    def set_new_transaction_false_on_charges
      @linked_account.set_new_transaction_false_on_charges
    end

end
