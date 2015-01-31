class StopOrder < ActiveRecord::Base
  belongs_to :charge
  belongs_to :merchant

  has_many :notes, as: :noteable

  validates_presence_of :charge, :status
  validates :status, inclusion: { in: %w(requested working succeeded failed canceled) }

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

  def cancelable?
    status == "requested" || status == "working"
  end
end