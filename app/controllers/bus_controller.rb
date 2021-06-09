class BusController < ApplicationController
	def index
		
	end
	def search
		puts params.inspect
		if params[:id].present?
			@bus = Bus.find(params[:id])
			@buses = Bus.where(start_point: @bus.start_point,end_point: @bus.end_point,status: "Available", travel_date: @bus.travel_date)
		else
		   @buses = Bus.where(start_point: params[:s_point],end_point: params[:e_point],status: "Available", travel_date: params[:date])
		end
	end
	def book
		if !user_signed_in?
			flash[:notice] = "please login to continue"
			redirect_to new_user_session_path(id: params[:id])
		end
		@seats = Bus.find(params[:id])		
	end
	def seats
		puts params.inspect
		@bus = Bus.find(params[:bus_id])
		
	end
end
