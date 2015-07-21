class MerchantAlias < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :financial_institution
end
