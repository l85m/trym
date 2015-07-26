class AddDefaultsToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :default_renewal_period, :integer
  end
end
