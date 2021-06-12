class AddcolunmToStatements < ActiveRecord::Migration[6.1]
  def change
  	add_column :statements, :bus_id, :integer
  	add_column :buses, :available_seats, :integer
  end
end
