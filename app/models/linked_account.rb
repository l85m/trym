class LinkedAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :financial_institution
  validates_uniqueness_of :user_id, scope: [:financial_institution_id, :destroyed_at], if: Proc.new { |link| link.destroyed_at.nil? }

  has_many :charges
  has_many :transaction_requests

  scope :not_destroyed, -> {where( destroyed_at: nil)}
  default_scope {not_destroyed}

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

  def delink
    #AccountDelinker.perform_async(id)
    update!( destroyed_at: Time.now )
    if charges.present?
      charges.recurring.update_all(linked_account_id: nil)
      charges.delete_all
    end
    true
  end

  def account_name
    financial_institution.name
  end

  #stub functions for forms
  def username
  end

  def password
  end

  def pin
  end

end