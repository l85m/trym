class AddCurrentJobIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_job_id, :text
  end
end
