class RemoveField < ActiveRecord::Migration[6.1]
  def change
  	remove_column :payments, :Regervation_id
  end
end
