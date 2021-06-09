class RemoveFields < ActiveRecord::Migration[6.1]
  def change
  	remove_column :reservations, :admin_id
  	remove_column :payments, :regervation_id
  	remove_column :statements, :status
  end
end
