class Bus < ApplicationRecord
	has_many :reservations
	has_many :payments
	def status_enum
      all_status = {1 => 'Available', 0 => 'Unavailable'}
      all_status.map{|key, val| [val, key]}
   end
end
