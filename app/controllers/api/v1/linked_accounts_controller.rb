class LinkedAccountsController < ApplicationController
  before_action :set_linked_account, only: [:show, :edit, :update, :destroy]

  # GET /linked_accounts
  # GET /linked_accounts.json
  def index
    @linked_accounts = LinkedAccount.all
  end

  # GET /linked_accounts/1
  # GET /linked_accounts/1.json
  def show
  end

  # GET /linked_accounts/new
  def new
    @linked_account = LinkedAccount.new
  end

  # GET /linked_accounts/1/edit
  def edit
  end

  # POST /linked_accounts
  # POST /linked_accounts.json
  def create
    @linked_account = LinkedAccount.new(linked_account_params)

    respond_to do |format|
      if @linked_account.save
        format.html { redirect_to @linked_account, notice: 'Linked account was successfully created.' }
        format.json { render :show, status: :created, location: @linked_account }
      else
        format.html { render :new }
        format.json { render json: @linked_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /linked_accounts/1
  # PATCH/PUT /linked_accounts/1.json
  def update
    respond_to do |format|
      if @linked_account.update(linked_account_params)
        format.html { redirect_to @linked_account, notice: 'Linked account was successfully updated.' }
        format.json { render :show, status: :ok, location: @linked_account }
      else
        format.html { render :edit }
        format.json { render json: @linked_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /linked_accounts/1
  # DELETE /linked_accounts/1.json
  def destroy
    @linked_account.destroy
    respond_to do |format|
      format.html { redirect_to linked_accounts_url, notice: 'Linked account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_linked_account
      @linked_account = LinkedAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def linked_account_params
      params.require(:linked_account).permit(:user_id, :financial_institution_id, :plaid_access_token, :last_successful_sync, :last_api_response, :mfa_question, :mfa_type, :destroyed_at, :status)
    end
end
