class MerchantAliasSerializer < ActiveModel::Serializer
  attributes :id, :alias
  has_one :merchant
  has_one :financial_institution
end
