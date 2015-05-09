class PlaidAccountDelinker
  include Sidekiq::Worker
  
  sidekiq_options retry: false

  def perform(linked_account_id)
    @link = LinkedAccount.find(linked_account_id)
    rebuild_plaid_user

    if @user.delete
      @link.update(plaid_access_token: nil)
    else
      Rails.logger.error "FAILED TO UNLINK Linked Account: #{@link.id}"
    end
  end

  def rebuild_plaid_user
    @user = Plaid::User.new
    @user.access_token = @link.plaid_access_token
    @user.permissions = ['connect']
  end

end