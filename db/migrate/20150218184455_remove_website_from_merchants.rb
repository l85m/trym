class RemoveWebsiteFromMerchants < ActiveRecord::Migration
  def change
  	remove_column :merchants, :website, :string
  end
end
