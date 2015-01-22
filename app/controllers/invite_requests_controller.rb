class InviteRequestsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  respond_to :html, :js

  def index
    @invite_requests = InviteRequest.all
    respond_with(@invite_requests)
  end

  def new
    @invite_request = InviteRequest.new
    respond_with(@invite_request)
  end

  def create
    @invite_request = InviteRequest.new(invite_request_params)
    @invite_request.save
    
    redirect_to root_path, flash: {info: "Thanks! We'll send you an invite soon."}
  end

  private
    def invite_request_params
      params.require(:invite_request).permit(:email)
    end
end
