class ChargeAlertMailer < ApplicationMailer
  
  def three_days_before_charge(user)
    @user = user
    mail to: @user.email, subjet: "3 days until your next charge", skip_premailer: true
  end
end
