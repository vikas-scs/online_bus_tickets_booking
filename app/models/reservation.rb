class Reservation < ApplicationRecord
	validates :bus_no , presence: true,
            uniqueness: true
	belongs_to :user
	belongs_to :bus
end
