class AddRecurringScoreToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :recurring_score, :integer, default: 0, null: false
  end
end
