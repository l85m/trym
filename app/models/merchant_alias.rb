class MerchantAlias < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :financial_institution

  scope :linked_to_merchant, -> {where.not( merchant_id: nil, ignore: true )}
end
