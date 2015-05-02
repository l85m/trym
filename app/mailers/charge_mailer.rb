class ChargeMailer < ApplicationMailer
  
  def three_days_before_charge(user, charges)
    @user = user
    @charges = charges
    mail to: @user.email, subject: "Trym Alert: Three days until you're charged for #{@charges.count} recurring expenses"
  end
 
  def monthly_summary(user, charges)
    @user = user
    @charges = charges
    mail to: @user.email, subject: "Trym Monthly Summary"
  end

end
