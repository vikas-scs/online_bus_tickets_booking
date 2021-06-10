class Bus < ApplicationRecord
	has_many :reservations
	has_many :payments
	belongs_to :admin
end
