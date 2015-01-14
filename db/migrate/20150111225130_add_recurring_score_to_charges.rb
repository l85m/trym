class AddRecurringScoreToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :recurring_score, :integer, default: 0, null: false
  end
end
