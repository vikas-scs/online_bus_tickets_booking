class AddNewFieldsToReservation < ActiveRecord::Migration[6.1]
  def change
  	add_column :statements, :reservation_id, :integer
  	add_column :statements, :no_seats, :integer
  	add_column :statements, :seat_fare, :float
  	add_column :statements, :description, :string
  end
end
