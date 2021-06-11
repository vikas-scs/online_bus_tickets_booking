class RemoveAdminFromBus < ActiveRecord::Migration[6.1]
  def change
  	remove_column :buses, :admin_id
  end
end
