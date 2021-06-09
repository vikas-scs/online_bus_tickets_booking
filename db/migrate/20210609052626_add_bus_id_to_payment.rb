class AddBusIdToPayment < ActiveRecord::Migration[6.1]
  def change
  	add_column :payments, :bus_id, :integer
  end
end
