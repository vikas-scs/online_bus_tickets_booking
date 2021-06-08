class RemoveFieldsFromBus < ActiveRecord::Migration[6.1]
  def change
  	remove_column :buses, :travel_date
  	add_column :buses, :travel_date, :date
  	add_column :buses, :start_time, :time 
  end
end
