class ChangeColonm < ActiveRecord::Migration[6.1]
  def change
  	rename_column :reservations, :seat_no, :no_seats
  	remove_column :payments, :reservation_id
  end
end
