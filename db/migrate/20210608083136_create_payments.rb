class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :regervation_id
      t.float :amount
      t.string :payment_status
      t.string :ref_id

      t.timestamps
    end
  end
end
