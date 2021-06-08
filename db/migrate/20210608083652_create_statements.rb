class CreateStatements < ActiveRecord::Migration[6.1]
  def change
    create_table :statements do |t|
      t.integer :user_id
      t.string :transaction_type
      t.float :amount
      t.float :refund_amount
      t.string :ref_id
      t.string :status
      t.float :remaining_balance

      t.timestamps
    end
  end
end
