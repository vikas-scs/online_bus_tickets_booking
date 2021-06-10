class CreateCancelFees < ActiveRecord::Migration[6.1]
  def change
    create_table :cancel_fees do |t|
      t.float :days_10
      t.float :days_7
      t.float :days_5
      t.float :hrs_72

      t.timestamps
    end
  end
end
