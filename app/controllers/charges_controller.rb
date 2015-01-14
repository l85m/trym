class ChargesController < ApplicationController
  before_action :set_charge, only: [:show, :edit, :update, :destroy]
  before_action :merchant_options, only: [:new, :edit]
  before_action :redirect_if_no_user

  respond_to :html

  def index
    @title = "charges"
    @charges = current_user.charges.recurring.with_merchant
    @charges_outlook_chart_data = ChargesOutlookChartData.new(current_user)
    respond_with(@charges)
  end

  def show
    respond_with(@charge)
  end

  def new
    @title = "new charge"
    @charge = Charge.new
    respond_to do |format|
      format.js
      format.html
    end
  end

  def edit
    @title = "edit charge"
    respond_to do |format|
      format.js
    end
  end

  def create
    Charge.new.create_or_update_from_params(charge_params.merge( user_id: current_user.id ))
    redirect_to charges_path, notice: "new charge successfully created"
  end

  def update
    if charge_params["recurring"].present? && charge_params.size == 1
      @charge.update(charge_params)
    else
      @charge.create_or_update_from_params(charge_params)
      redirect_to charges_path
    end
  end

  def destroy
    @charge.destroy
    respond_with(@charge)
  end

  private

    def merchant_options
      merchants = Merchant.names_and_websites
      @merchant_names_and_websites = merchants.collect{ |n,w| [n.upcase, w] }.to_h
      @merchant_names = merchants.keys
    end

    def redirect_if_no_user
      unless current_user.present?
        flash.now[:notice] = "Please sign in first"
        redirect_to new_user_session_path 
      end
    end

    def set_charge
      @charge = Charge.find(params[:id])
    end

    def charge_params
      p = params.require(:charge).permit(:merchant_name, :merchant_website, :description, :amount, :recurring,
                                         :last_date_billed, :renewal_period_in_weeks, :renewal_period_in_words)
    end

end