class DropRefund < ActiveRecord::Migration[6.1]
  def change
  	drop_table :refunds
  end
end
