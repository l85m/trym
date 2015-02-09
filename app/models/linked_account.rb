class LinkedAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :financial_institution
  validates_uniqueness_of :user_id, scope: :financial_institution_id

  has_many :charges
  has_many :transaction_requests

  #after_save :create_charges_from_transaction_data

  scope :has_data, -> {where.not(transaction_data: nil)}

  def error_message
    return nil if (last_api_response.nil? || last_api_response["response_code"].to_i < 202)
    PlaidErrorHandler.new(last_api_response).message_for_user
  end

  def mfa_prompt
    return nil unless (mfa_question.present? && mfa_type.present?)
    if mfa_type == "question"
      mfa_question
    else
      delivered_to = mfa_question.split(' ').last
      delivery_method = delivered_to.include?("@") ? "email" : "phone"
      "Please enter the security code which #{financial_institution.name} sent to your #{delivered_to} #{delivery_method}"
    end
  end

  def account_name
    financial_institution.name
  end

  #TODO: find way to get rid of stub functions for forms
  def username
  end

  def password
  end

  def pin
  end

  private

  def create_charges_from_transaction_data
    if transaction_data.present? && transaction_data_changed?
      PlaidTransactionParser.new(self)
    end
  end

end