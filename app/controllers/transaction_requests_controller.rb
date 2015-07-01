class TransactionRequestsController < ApplicationController
  before_action :set_transaction_request, only: [:show, :edit, :update, :destroy]

  # GET /transaction_requests
  # GET /transaction_requests.json
  def index
    @transaction_requests = TransactionRequest.all
  end

  # GET /transaction_requests/1
  # GET /transaction_requests/1.json
  def show
  end

  # GET /transaction_requests/new
  def new
    @transaction_request = TransactionRequest.new
  end

  # GET /transaction_requests/1/edit
  def edit
  end

  # POST /transaction_requests
  # POST /transaction_requests.json
  def create
    @transaction_request = TransactionRequest.new(transaction_request_params)

    respond_to do |format|
      if @transaction_request.save
        format.html { redirect_to @transaction_request, notice: 'Transaction request was successfully created.' }
        format.json { render :show, status: :created, location: @transaction_request }
      else
        format.html { render :new }
        format.json { render json: @transaction_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transaction_requests/1
  # PATCH/PUT /transaction_requests/1.json
  def update
    respond_to do |format|
      if @transaction_request.update(transaction_request_params)
        format.html { redirect_to @transaction_request, notice: 'Transaction request was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction_request }
      else
        format.html { render :edit }
        format.json { render json: @transaction_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transaction_requests/1
  # DELETE /transaction_requests/1.json
  def destroy
    @transaction_request.destroy
    respond_to do |format|
      format.html { redirect_to transaction_requests_url, notice: 'Transaction request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction_request
      @transaction_request = TransactionRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_request_params
      params.require(:transaction_request).permit(:linked_account_id, :data)
    end
end
