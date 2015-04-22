class ChangeCancelationCriteriaOnMerchants < ActiveRecord::Migration
  def change
  	remove_column :merchants, :cancelation_fields, :text, array: true
  	add_column :merchants, :cancelation_fields, :json
  end
end
