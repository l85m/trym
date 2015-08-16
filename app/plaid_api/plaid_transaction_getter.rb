class PlaidTransactionGetter
  include Sidekiq::Worker
  
  sidekiq_options retry: false

  def perform(linked_account_id)
    @link = LinkedAccount.find(linked_account_id)
    was_delayed = @link.status == "delayed"

    @link.update( status: "analyzing" )
    connect_to_plaid

    @link.update prep_linked_account_params.merge({last_api_response: @user.api_res})
    
    if @user.transactions.present?
      parser = PlaidTransactionParser.new @user.transactions, @link.transaction_requests.create
      ChargeBuilder.new parser.transaction_list
    end
    @link.update( status: "linked" )
    
    LinkedAccountMailer.send('delayed_account_linking', @link).deliver if was_delayed
    notify_client
  end

  def connect_to_plaid
    rebuild_plaid_user
    @user.get_connect
  end

  def rebuild_plaid_user
    @user = Plaid::User.new
    @user.access_token = @link.plaid_access_token
    @user.permissions = ['connect']
  end

  def prep_linked_account_params
    if @user.api_res['response_code'] == 200
      { last_successful_sync: Time.now }
    elsif @user.api_res['response_code'] == 201
      mfa = @user.pending_mfa_questions.first.to_a.flatten
      {
        mfa_type: mfa.first,
        mfa_question: mfa.last
      }
    else
      {}
    end
  end

  def notify_client
    button_disabled_state = "false"
    button_icon = "check"
    button_text = "Linked"
    button_tooltip = ""
    button_link = '/linked_accounts/' + @link.id.to_s
    flash = "Done syncing your account.  <a href='#{Rails.application.routes.url_helpers.linked_account_path(@link)}'>Click here</a> to see review your transactions."
 
    @link.push_update_to_client({
      button_icon: button_icon, 
      button_text: button_text, 
      button_tooltip: button_tooltip, 
      button_link: button_link, 
      button_disabled_state: button_disabled_state, 
      flash: flash
    })
  end

end