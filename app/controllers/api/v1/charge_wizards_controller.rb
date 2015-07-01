class ChargeWizardsController < ApplicationController
  before_action :set_charge_wizard, only: [:show, :edit, :update, :destroy]

  # GET /charge_wizards
  # GET /charge_wizards.json
  def index
    @charge_wizards = ChargeWizard.all
  end

  # GET /charge_wizards/1
  # GET /charge_wizards/1.json
  def show
  end

  # GET /charge_wizards/new
  def new
    @charge_wizard = ChargeWizard.new
  end

  # GET /charge_wizards/1/edit
  def edit
  end

  # POST /charge_wizards
  # POST /charge_wizards.json
  def create
    @charge_wizard = ChargeWizard.new(charge_wizard_params)

    respond_to do |format|
      if @charge_wizard.save
        format.html { redirect_to @charge_wizard, notice: 'Charge wizard was successfully created.' }
        format.json { render :show, status: :created, location: @charge_wizard }
      else
        format.html { render :new }
        format.json { render json: @charge_wizard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /charge_wizards/1
  # PATCH/PUT /charge_wizards/1.json
  def update
    respond_to do |format|
      if @charge_wizard.update(charge_wizard_params)
        format.html { redirect_to @charge_wizard, notice: 'Charge wizard was successfully updated.' }
        format.json { render :show, status: :ok, location: @charge_wizard }
      else
        format.html { render :edit }
        format.json { render json: @charge_wizard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /charge_wizards/1
  # DELETE /charge_wizards/1.json
  def destroy
    @charge_wizard.destroy
    respond_to do |format|
      format.html { redirect_to charge_wizards_url, notice: 'Charge wizard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_charge_wizard
      @charge_wizard = ChargeWizard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def charge_wizard_params
      params.require(:charge_wizard).permit(:progress, :in_progress, :user_id)
    end
end
