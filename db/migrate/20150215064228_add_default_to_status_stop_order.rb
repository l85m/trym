class AddDefaultToStatusStopOrder < ActiveRecord::Migration
  def change
  	change_column_default :stop_orders, :status, true
  end
end
