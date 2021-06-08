class CreateBuses < ActiveRecord::Migration[6.1]
  def change
    create_table :buses do |t|
      t.string :bus_no
      t.string :start_point
      t.string :end_point
      t.integer :total_seats
      t.string :status
      t.string :travel_date, :date
      t.timestamps
    end
  end
end
