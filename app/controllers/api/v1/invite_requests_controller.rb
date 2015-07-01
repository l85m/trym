class InviteRequestsController < ApplicationController
  before_action :set_invite_request, only: [:show, :edit, :update, :destroy]

  # GET /invite_requests
  # GET /invite_requests.json
  def index
    @invite_requests = InviteRequest.all
  end

  # GET /invite_requests/1
  # GET /invite_requests/1.json
  def show
  end

  # GET /invite_requests/new
  def new
    @invite_request = InviteRequest.new
  end

  # GET /invite_requests/1/edit
  def edit
  end

  # POST /invite_requests
  # POST /invite_requests.json
  def create
    @invite_request = InviteRequest.new(invite_request_params)

    respond_to do |format|
      if @invite_request.save
        format.html { redirect_to @invite_request, notice: 'Invite request was successfully created.' }
        format.json { render :show, status: :created, location: @invite_request }
      else
        format.html { render :new }
        format.json { render json: @invite_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invite_requests/1
  # PATCH/PUT /invite_requests/1.json
  def update
    respond_to do |format|
      if @invite_request.update(invite_request_params)
        format.html { redirect_to @invite_request, notice: 'Invite request was successfully updated.' }
        format.json { render :show, status: :ok, location: @invite_request }
      else
        format.html { render :edit }
        format.json { render json: @invite_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invite_requests/1
  # DELETE /invite_requests/1.json
  def destroy
    @invite_request.destroy
    respond_to do |format|
      format.html { redirect_to invite_requests_url, notice: 'Invite request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invite_request
      @invite_request = InviteRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invite_request_params
      params.require(:invite_request).permit(:email)
    end
end
