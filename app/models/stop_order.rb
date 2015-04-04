class StopOrder < ActiveRecord::Base
  belongs_to :charge
  belongs_to :merchant

  has_many :notes, as: :noteable

  validates_presence_of :charge, :status
  validates_inclusion_of :option, in: ["cancel_all", "downgrade", "upgrade", "find_deals", nil]
  validates :status, inclusion: { in: %w(started requested working succeeded failed canceled) }

  scope :active_or_complete, -> {where(status: ["requested", "working", "succeeded"]).first}
  scope :active, -> {where(status: ["requested", "working"]).first}

  def status_message
    case status
    when "requested"
      "We've recieved your cancelation request for #{merchant.name} and will start working on it soon"
    when "working"
      "We're working on canceling your account with #{merchant.name}, we'll let you know if we have any issues"
    when "succeeded"
      "We've succesfully canceled your account with #{merchant.name}! Please see below for details"
    when "failed"
      "Unfortunately we were not able to cancel your account with #{merchant.name}. Please see below for details"
    end
  end

  def merchant
    charge.merchant
  end

  def type_of_request
    case option
    when "cancel_all"
      "Cancel Your Entire Account / Service"
    when "downgrade"
      "Downgrade or Cancel Part of Your Service"
    when "upgrade"
      "Upgrade or Add New Services"
    when "find_deals"
      "Search for Better Deal"
    else
      nil
    end
  end

  def cancelable?
    status == "requested" || status == "working"
  end

  def cancelation_fields
    if charge.merchant.present? && charge.merchant.cancelation_fields.present?
      charge.merchant.cancelation_fields.map(&:to_sym)
    else
      []
    end
  end
end