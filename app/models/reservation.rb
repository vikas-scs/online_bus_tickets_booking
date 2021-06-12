class Reservation < ApplicationRecord
	belongs_to :user
	belongs_to :bus
	has_many :statements
end
