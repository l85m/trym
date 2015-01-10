class TransactionDataRequestsController < ApplicationController
  before_action :set_transaction_data_request, only: :show
  respond_to :html, :js, :json

  def show
    respond_with(@transaction_data_request)
  end

  def new
    @transaction_data_request = TransactionDataRequest.new
    respond_with(@transaction_data_request)
  end

  def create
    @transaction_data_request = TransactionDataRequest.create_and_start_scan(transaction_data_request_params)
  end

  private
    def set_transaction_data_request
      @transaction_data_request = TransactionDataRequest.find(params[:id])
    end

    def transaction_data_request_params
      params.require(:transaction_data_request).permit(:username, :password, :financial_institution).merge({ user: current_user })
    end
end
