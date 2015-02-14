class GetPlaidTransactions
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(linked_account_id)
    @params = params
    @link = LinkedAccount.find(linked_account_id)
    
    connect_to_plaid
    update_linked_account
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

  def account_linked_and_transaction_data_present?
  	@user.transactions = @user.transactions - @link.transaction_requests.order(created_at: :desc).first.data
  end
end