class AddBusIdToPay < ActiveRecord::Migration[6.1]
  def change
  	rename_column :payments, :regervation_id, :reservation_id
  end
end
