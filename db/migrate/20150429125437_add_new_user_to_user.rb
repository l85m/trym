class AddNewUserToUser < ActiveRecord::Migration
  def change
  	remove_column :users, :current_job_id, :text
  	add_column :users, :show_intro, :boolean, null: false, default: true
  end
end
