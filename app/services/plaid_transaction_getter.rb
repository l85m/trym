class PlaidTransactionGetter
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(linked_account_id)
    @link = LinkedAccount.find(linked_account_id)
    
    connect_to_plaid
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

end