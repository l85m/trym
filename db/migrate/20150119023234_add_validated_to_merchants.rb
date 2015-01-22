class AddValidatedToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :validated, :boolean, null: false, default: false
  end
end
