class TrymCategoriesController < ApplicationController
  before_action :set_trym_category, only: [:show, :edit, :update, :destroy]

  # GET /trym_categories
  # GET /trym_categories.json
  def index
    @trym_categories = TrymCategory.all
  end

  # GET /trym_categories/1
  # GET /trym_categories/1.json
  def show
  end

  # GET /trym_categories/new
  def new
    @trym_category = TrymCategory.new
  end

  # GET /trym_categories/1/edit
  def edit
  end

  # POST /trym_categories
  # POST /trym_categories.json
  def create
    @trym_category = TrymCategory.new(trym_category_params)

    respond_to do |format|
      if @trym_category.save
        format.html { redirect_to @trym_category, notice: 'Trym category was successfully created.' }
        format.json { render :show, status: :created, location: @trym_category }
      else
        format.html { render :new }
        format.json { render json: @trym_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trym_categories/1
  # PATCH/PUT /trym_categories/1.json
  def update
    respond_to do |format|
      if @trym_category.update(trym_category_params)
        format.html { redirect_to @trym_category, notice: 'Trym category was successfully updated.' }
        format.json { render :show, status: :ok, location: @trym_category }
      else
        format.html { render :edit }
        format.json { render json: @trym_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trym_categories/1
  # DELETE /trym_categories/1.json
  def destroy
    @trym_category.destroy
    respond_to do |format|
      format.html { redirect_to trym_categories_url, notice: 'Trym category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trym_category
      @trym_category = TrymCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trym_category_params
      params.require(:trym_category).permit(:name, :recurring, :description)
    end
end
