class ChargeAlertMailer < ApplicationMailer
  
  def three_days_before_charge(user, charges)
    @user = user
    @charges = charges
    mail to: @user.email, subject: "Charge Alert: Three days until next charges for $#{(@charges.collect(&:amount).inject(:+) / 100.0).to_i}"
  end
end
