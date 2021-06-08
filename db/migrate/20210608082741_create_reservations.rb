class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.integer :bus_id
      t.integer :user_id
      t.integer :seat_no
      t.float :fare
      t.integer :admin_id
      t.string :Reserve_status

      t.timestamps
    end
  end
end
