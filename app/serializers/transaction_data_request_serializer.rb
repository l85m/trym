class TransactionDataRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :failure_reason
  has_one :user
  has_one :financial_institution
end
