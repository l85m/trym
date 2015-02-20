class PlaidTransactionGetter
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(linked_account_id)
    @link = LinkedAccount.find(linked_account_id)
    
    connect_to_plaid
    @link.update( prep_linked_account_params.merge({last_api_response: @user.api_res}) )
    ChargeBuilder.new( @link.transaction_requests.create(data: @user.transactions) ) if @user.transactions.present?
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
    end
  end

end