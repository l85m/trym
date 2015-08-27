class LinkedAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :financial_institution
  validates_uniqueness_of :user_id, scope: [:financial_institution_id, :destroyed_at], if: Proc.new { |link| link.destroyed_at.nil? }
  validates :status, inclusion: { in: %w(started mfa syncing analyzing linked unlinked delayed) }

  has_many :charges
  has_many :transaction_requests
  has_many :transactions, through: :transaction_requests

  scope :linked, -> {where( status: ["syncing", "analyzing", "linked"] )}
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
      "Please enter the security code which #{account_name} sent to your #{delivered_to} #{delivery_method}"
    end
  end

  def plaid_webhook_handler(params)
    case params["code"].to_i
    when 0
      true
    when 1..2
      button_icon = "circle-o-notch fa-spin"
      button_text = "analyzing"
      button_tooltip = "Trym is searching through your transactions from #{account_name} to indentify potentially recurring charges.  This should only take a few seconds."
      button_link = '#'
      flash = ''
      button_disabled_state = "disabled"
      PlaidTransactionGetter.perform_async(id)
      push_update_to_client({
        button_icon: button_icon, 
        button_text: button_text, 
        button_tooltip: button_tooltip, 
        button_link: button_link, 
        button_disabled_state: button_disabled_state,
        flash: flash
      })
    when 3..4
      true
    when 1205
      button_icon = "warning"
      button_text = "locked"
      button_tooltip = "Please log into #{account_name}'s website to unlock your account.  Once you've done that click here to relink your account"
      button_link = Rails.application.routes.url_helpers.new_linked_account_path
      button_disabled_state = "false"
      flash = "It appears your account is locked.  Please visit #{account_name}'s website to unlock it."
      push_update_to_client({
        button_icon: button_icon, 
        button_text: button_text, 
        button_tooltip: button_tooltip, 
        button_link: button_link, 
        button_disabled_state: button_disabled_state, 
        flash: flash
      })    
    else
      Rails.logger.error "Trym Webhook Unhandled Response for linked_account=#{id}.  Response Body: #{params.inspect}"
    end
  end

  def delink
    AccountDelinker.perform_async(id)
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

  def name
    financial_institution.name
  end


  #stub functions for forms
  def username
  end

  def password
  end

  def pin
  end

  def push_update_to_client(message)
    channel_name = 'private-user-' + user.id.to_s + '-channel'
    Pusher[channel_name].trigger( "linked-account-notifications", {
      linked_account_id: id,
      linked_account_name: account_name,
      message: message
    })
  end

end