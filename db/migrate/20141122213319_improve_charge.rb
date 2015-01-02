class ImproveCharge < ActiveRecord::Migration
  def change
  	change_table :charges do |t|
  		t.rename :end, :end_date
  		t.rename :start, :start_date
  		t.rename :renewal_period_in_days, :renewal_period_in_months
  		t.date   :billing_day
  		t.boolean :active
		end
  end
end
