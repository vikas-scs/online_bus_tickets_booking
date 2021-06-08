class BusController < ApplicationController
	def index
		
	end
	def search
		puts params.inspect
		@buses = Bus.where(start_point: params[:s_point],end_point: params[:e_point],status: "Available", travel_date: params[:date])
		puts @buses
		puts "hello"
	end
	def book
		if !user_signed_in?
			flash[:notice] = "please login to continue"
			redirect_to new_user_session_path(id: params[:id])
		end
		@seats = Bus.find(params[:id])		
	end
	def seats
		
	end
end
