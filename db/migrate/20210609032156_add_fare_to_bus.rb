class AddFareToBus < ActiveRecord::Migration[6.1]
  def change
  	add_column :buses, :fare, :float
  end
end
