class AddBusIdToreservation < ActiveRecord::Migration[6.1]
  def change
  	add_column :reservations, :bus_no, :string
  end
end
