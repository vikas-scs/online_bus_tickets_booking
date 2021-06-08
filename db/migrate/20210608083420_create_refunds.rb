class CreateRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :refunds do |t|
      t.integer :days
      t.float :percentage

      t.timestamps
    end
  end
end
