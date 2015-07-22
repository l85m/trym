class RemoveTypeFromMerchants < ActiveRecord::Migration
  def change
  	remove_column :merchants, :type, :string
  end
end
