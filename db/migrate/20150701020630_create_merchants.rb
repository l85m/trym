class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :name
      t.string :type
      t.boolean :validated
      t.integer :recurring_score
      t.belongs_to :trym_category, index: true, foreign_key: true
      t.json :cancellation_fields

      t.timestamps null: false
    end
  end
end
