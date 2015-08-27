class AccountDelinker
  include Sidekiq::Worker

  def perform(linked_account_id)
    @link = LinkedAccount.find(linked_account_id)
    delink_account
  end

  private

  def delink_account
  	Plaid.set_user(@link.plaid_access_token, ['connect']).delete_user
  end
end