class LinkedAccountsController < ApplicationController
  before_action :authenticate_user!, except: :plaid_webhook
  before_action :set_linked_account, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, only: :plaid_webhook

  respond_to :html, :js, :json

  def show
    unless request_format == :json
      @charges = @linked_account.charges.sort_by_recurring_score.page(params[:page])
    end

    respond_with(@linked_account)
  end

  def index
    @linked_accounts = current_user.linked_accounts
    render layout: "manage_account"
  end

  def new
    @financial_institution = FinancialInstitution.find(params[:financial_institution_id]) if params[:financial_institution_id].present?
    @linked_account = LinkedAccount.new
    respond_with(@linked_account)
  end

  def create
    @linked_account = LinkedAccount.find_or_create_by(linked_account_params)
    if @linked_account.errors.present?
      render 'error'
    else
      @linked_account.update( last_api_response: nil )
      
      job_id = AccountLinker.perform_async( account_linker_params, @linked_account.id )
      @linked_account.user.update( current_job_id: job_id ) 
    end
  end

  def plaid_webhook
    @linked_account = LinkedAccount.find_by_plaid_access_token( params["access_token"] )
    
    if @linked_account.present?
      @linked_account.plaid_webhook_handler(params)
    else
      Rails.logger.error "Trym Webhook For Orphaned Account!! linked_account=#{@linked_account.id}.  Response Body: #{params.inspect}"
    end

    head :ok, content_type: "text/html"
  end

  def edit
  end

  def update
    #TODO: Handle Reauth / Account Destroy
    if ["201","402"].include? @linked_account.last_api_response["response_code"]
      @linked_account.update( last_api_response: nil )
      
      job_id = AccountLinker.perform_async( mfa_params, @linked_account.id )
      @link.user.update( current_job_id: job_id ) 
    end
  end

  def destroy
    @linked_account.delink
    redirect_to root_path
  end

  private
    def set_linked_account
      @linked_account = current_user.linked_accounts.find(params[:id])
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

end
