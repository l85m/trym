class ChangeRenewalPeriodOnCharges < ActiveRecord::Migration
  def change
  	rename_column :charges, :renewal_period_in_months, :renewal_period_in_weeks
  end
end
