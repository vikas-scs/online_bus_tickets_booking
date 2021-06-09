class ChangeColoumType < ActiveRecord::Migration[6.1]
  def change
  	change_column :users, :mobile, :string
  end
end
