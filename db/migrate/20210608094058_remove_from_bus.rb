class RemoveFromBus < ActiveRecord::Migration[6.1]
  def change
  	remove_column :buses, :travel_date
  	remove_column :buses, :date
  	add_column :buses, :travel_date, :datetime
  	add_column :buses, :travel_hrs, :integer
  end
end
