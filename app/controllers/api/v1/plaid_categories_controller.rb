class PlaidCategoriesController < ApplicationController
  before_action :set_plaid_category, only: [:show, :edit, :update, :destroy]

  # GET /plaid_categories
  # GET /plaid_categories.json
  def index
    @plaid_categories = PlaidCategory.all
  end

  # GET /plaid_categories/1
  # GET /plaid_categories/1.json
  def show
  end

  # GET /plaid_categories/new
  def new
    @plaid_category = PlaidCategory.new
  end

  # GET /plaid_categories/1/edit
  def edit
  end

  # POST /plaid_categories
  # POST /plaid_categories.json
  def create
    @plaid_category = PlaidCategory.new(plaid_category_params)

    respond_to do |format|
      if @plaid_category.save
        format.html { redirect_to @plaid_category, notice: 'Plaid category was successfully created.' }
        format.json { render :show, status: :created, location: @plaid_category }
      else
        format.html { render :new }
        format.json { render json: @plaid_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plaid_categories/1
  # PATCH/PUT /plaid_categories/1.json
  def update
    respond_to do |format|
      if @plaid_category.update(plaid_category_params)
        format.html { redirect_to @plaid_category, notice: 'Plaid category was successfully updated.' }
        format.json { render :show, status: :ok, location: @plaid_category }
      else
        format.html { render :edit }
        format.json { render json: @plaid_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plaid_categories/1
  # DELETE /plaid_categories/1.json
  def destroy
    @plaid_category.destroy
    respond_to do |format|
      format.html { redirect_to plaid_categories_url, notice: 'Plaid category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plaid_category
      @plaid_category = PlaidCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plaid_category_params
      params.require(:plaid_category).permit(:plaid_type, :hierarchy, :plaid_id, :trym_category_id)
    end
end
