class LinkedAccountMailer < ApplicationMailer
  
  def delayed_account_linking(linked_account)
    @linked_account = linked_account
    @user = linked_account.user
    mail to: @user.email, subject: "Trym has finished linking to your #{linked_account.name} account"
  end

end
