class MerchantAliasesController < InheritedResources::Base
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
  	@merchant_aliases = MerchantAlias.all
  end

  private

  	def authenticate_admin!
  		unless current_user.admin
  			access_denied(nil)
  		end
  	end

    def merchant_alias_params
      params.require(:merchant_alias).permit(:alias, :merchant_id, :financial_institution_id)
    end
end

