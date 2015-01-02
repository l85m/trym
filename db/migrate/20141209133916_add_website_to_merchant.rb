class AddWebsiteToMerchant < ActiveRecord::Migration
  def change
    add_column :merchants, :website, :string
  end
end
