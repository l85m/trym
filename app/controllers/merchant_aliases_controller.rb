class MerchantAliasesController < InheritedResources::Base

  private

    def merchant_alias_params
      params.require(:merchant_alias).permit(:alias, :merchant_id, :financial_institution_id)
    end
end

