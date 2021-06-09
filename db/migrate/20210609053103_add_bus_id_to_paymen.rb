class AddBusIdToPaymen < ActiveRecord::Migration[6.1]
  def change
  	remove_column :payments, :admin_id, :integer
  end
end
