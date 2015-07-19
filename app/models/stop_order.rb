class StopOrder < ActiveRecord::Base
  attr_accessor :skip_cancelation_data_validation
  belongs_to :charge
  accepts_nested_attributes_for :charge, update_only: true
  
  belongs_to :merchant
  belongs_to :operator, class_name: "User"

  has_many :notes, as: :noteable

  validates_presence_of :charge, :status
  validates_inclusion_of :option, in: ["cancel_all", "downgrade", "upgrade", "find_deals", nil]
  validates :status, inclusion: { in: %w(started requested working succeeded failed canceled) }
  validates :contact_preference, inclusion: { in: %w(call text email) }
  
  validate :required_cancelation_fields_must_be_present_on_requested_records, unless: :skip_cancelation_data_validation?
  validate :required_cancelation_data_must_be_valid_on_requested_records, unless: :skip_cancelation_data_validation?
  
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
      case option
      when "cancel_all"
        "We've finished canceling your account with #{charge.descriptor}! Check your email for a confirmation."
      when "downgrade"
        "We've finished downgrading your account with #{charge.descriptor}! Check your email for a confirmation."
      when "upgrade"
        "We've finished upgrading your account with #{charge.descriptor}! Check your email for a confirmation."
      when "find_deals"
        "We sent you some reccomendations for better deals, feel free to start a new trym request if you want us to look for something else."
      end
    when "failed"
      "Unfortunately we were not able to complete your trym request for #{charge.descriptor}. Please see below for details"
    end
  end

  def merchant
    if charge.present? 
      charge.merchant
    else
      nil
    end
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
      "Cancel All Services"
    when "downgrade"
      "Downgrade Services"
    when "upgrade"
      "Upgrade Services"
    when "find_deals"
      "Search for Better Deal"
    else
      nil
    end
  end

  def progress_perc
    {started: "5%", requested: "40%", working: "60%", succeeded: "100%", failed: "100%"}[status.to_sym]
  end

  def progress_class
    {started: "default", requested: "default", working: "default", succeeded: "default", failed: "danger"}[status.to_sym]
  end

  def cancelable?
    status == "requested" || status == "working"
  end

  def cancelation_fields
    if merchant.present? && merchant.cancelation_fields.present?
      merchant.cancelation_fields.sort_by{ |_,h| h["required"] ? 0 : 1 }.to_h.keys.map(&:to_sym)
    else
      [:address, :phone_number_on_account]
    end
  end

  def missing_required_fields
    if merchant.present? && merchant.cancelation_fields.present? && merchant.required_cancelation_fileds.present?
      present_fields = ( cancelation_data.presence || {} ).select{ |_,v| v.present? }.keys.map(&:to_sym)
      required_fields = merchant.required_cancelation_fileds.map(&:to_sym) + (option == "cancel_all" ? [] : [:change_description])
      required_fields - present_fields
    else
      []
    end
  end

  def missing_charge_fields
    return [] unless charge.present?
    charge_fields.keys.reject{ |field| charge.send(field).present? }
  end

  def charge_fields
    return {} unless charge.present?
    {
      amount: [:currency, "How much is your average bill?", "", charge.amount.present? ? charge.amount / 100.0 : nil ],
      billing_day: [:string, "When is your next charge?", "Estimate if not sure", charge.billing_day ],
      renewal_period_in_weeks: [:string, "How often are you charged?", "", charge.renewal_period_in_weeks]
    }
  end

  def skip_cancelation_data_validation?
    skip_cancelation_data_validation == 'true' || skip_cancelation_data_validation == true
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

  def required_cancelation_fields_must_be_present_on_requested_records
    if status != "started"
      missing_fields = missing_charge_fields + missing_required_fields
      missing_fields.each do |required_field|
        errors.add( required_field , "can't be blank" )
      end
    end
  end

  def required_cancelation_data_must_be_valid_on_requested_records
    if status != "started" && cancelation_data.present?
      cancelation_data.each do |field, value|
        if field.include?("phone_number") && value.phony_formatted(strict: true, normalize: :US).nil?
          errors.add( field , "must be a valid US phone number" )
        elsif field.include?("last_4_digits_of_social_security_number") 
          if value.size != 4
            errors.add( field, "must be complete")
          elsif value.match(/\D/)
            errors.add( field, "must be a number")
          end
        end
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