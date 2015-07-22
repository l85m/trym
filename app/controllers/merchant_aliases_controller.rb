class MerchantAliasesController < InheritedResources::Base
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :find_merchant_alias, except: :index

  def index
    if params[:show_ignored_aliases]
      @merchant_aliases = MerchantAlias.where(ignore: true).page(params[:page])
    elsif params[:show_mapped_aliases]
      @merchant_aliases = MerchantAlias.where.not(merchant_id: nil).page(params[:page])
    else
      @merchant_aliases = MerchantAlias.where(ignore: false).page(params[:page])
    end
  end

  def update
    @saved = @merchant_alias.update(merchant_alias_params)

    if merchant_alias_params[:merchant_id]
      render json: nil, status: @saved ? :ok : :error
    end
  end

  private
    
    def find_merchant_alias
      @merchant_alias = MerchantAlias.find(params[:id])
    end

  	def authenticate_admin!
  		unless current_user.admin
  			access_denied(nil)
  		end
  	end

    def merchant_alias_params
      params.require(:merchant_alias).permit(:merchant_id, :ignore)
    end
end

