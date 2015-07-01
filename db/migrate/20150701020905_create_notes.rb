class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :noteable_id
      t.string :noteable_type
      t.text :body
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
