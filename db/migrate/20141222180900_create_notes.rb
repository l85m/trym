class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :noteable, polymorphic: true, index: true
      t.text :body
      t.references :user, index: true

      t.timestamps
    end
  end
end
