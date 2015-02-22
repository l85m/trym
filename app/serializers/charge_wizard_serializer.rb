class ChargeWizardSerializer < ActiveModel::Serializer
  attributes :id, :progress, :in_progress
  has_one :linked_account
end
