class AddDefinitelyRecurringIfInRenewalPeriodToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :definitely_recurring_if_in_renewal_period, :boolean, default: false
  end
end
