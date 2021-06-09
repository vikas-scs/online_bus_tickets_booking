class AddBusIdToPayment < ActiveRecord::Migration[6.1]
  def change
  	remove_column :payments, :regervation
  	add_column :payments, :bus_id, :integer
  end
end
