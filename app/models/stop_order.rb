class StopOrder < ActiveRecord::Base
  belongs_to :charge
  belongs_to :merchant
  belongs_to :operator, class_name: "User"

  has_many :notes, as: :noteable

  validates_presence_of :charge, :status
  validates_inclusion_of :option, in: ["cancel_all", "downgrade", "upgrade", "find_deals", nil]
  validates :status, inclusion: { in: %w(started requested working succeeded failed canceled) }
  validates :contact_preference, inclusion: { in: %w(call text email) }
  validate :required_cancelation_fileds_must_be_present_on_requested_records

  scope :active_or_complete, -> {where(status: ["requested", "working", "succeeded"])}
  scope :active, -> {where(status: ["requested", "working"]).first}
  scope :with_charge, -> {joins(:charge)}

  before_save :make_charge_recurring
  before_save :update_account_details_if_reusable

  after_destroy :destroy_temporary_charge

  def status_message
    case status
    when "requested"
      "We've recieved your trym request for #{charge.descriptor} and will start working on it soon"
    when "working"
      "We're working on your request for #{charge.descriptor}, we'll let you know if we have any issues"
    when "succeeded"
      "We've finished canceling your account with #{charge.descriptor}! Please contact us if you have any questions."
    when "failed"
      "Unfortunately we were not able to cancel your account with #{charge.descriptor}. Please see below for details"
    end
  end

  def merchant
    charge.merchant
  end

  def user
    charge.user
  end

  def account_details
    user.present? ? user.account_detail : nil
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
    if merchant.present? && merchant.cancelation_fields.present?
      merchant.cancelation_fields.sort_by{ |_,h| h["required"] ? 0 : 1 }.to_h.keys.map(&:to_sym)
    else
      []
    end
  end

  def missing_required_fields
    if merchant.present? && merchant.cancelation_fields.present? && merchant.required_cancelation_fileds.present?
      present_fields = ( cancelation_data.presence || {} ).select{ |_,v| v.present? }.keys.map(&:to_sym)
      required_fields = merchant.required_cancelation_fileds.map(&:to_sym) + (option == "cancel_all" ? [] : [:change_description])
      required_fields - present_fields
    end
  end

  private

  def update_account_details_if_reusable
    if merchant.present? && merchant.cancelation_fields.present? && merchant.reusable_cancelation_fields.present?
      reusable_data = cancelation_data.select{ |k,_| merchant.reusable_cancelation_fields.include? k.to_s }
      if reusable_data.present?
        account_details.update( account_data: account_details.account_data.merge( reusable_data ) )
      end
    end
  end

  def required_cancelation_fileds_must_be_present_on_requested_records
    if status != "started" && missing_required_fields.present?
      missing_required_fields.each do |required_field|
        errors.add( required_field , "can't be blank" )
      end
    end
  end

  def make_charge_recurring
    if !charge.recurring && status == "requested"
      charge.update( recurring: true )
    end
  end

  def destroy_temporary_charge
    if !charge.recurring && status == "started"
      charge.delete
    end
  end

end