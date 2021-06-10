class AddFieldsToAdmin < ActiveRecord::Migration[6.1]
  def change
  	add_column :admins, :wallet, :float, default: 0
  	add_column :buses, :admin_id, :integer
  	add_column :statements, :admin_id, :integer
  end
end
