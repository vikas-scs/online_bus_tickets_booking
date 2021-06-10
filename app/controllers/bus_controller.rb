class BusController < ApplicationController
	def index
		
	end
	def search
		puts params.inspect
		if params[:id].present?
			@bus = Bus.find(params[:id])
			@buses = Bus.where(start_point: @bus.start_point,end_point: @bus.end_point)
		elsif !params[:s_point].present? && !params[:e_point].present? && !params[:date].present?
            	flash[:notice] = "please enter source and destination"
				redirect_to root_path
		else
		    if params[:s_point].present? && params[:e_point].present? && params[:date].present?
		   	   @upcase1 = params[:s_point].upcase
		   	   @upcase2 = params[:e_point].upcase
		   	   @down1 = params[:s_point].downcase
		   	   @down2 = params[:e_point].downcase
		       @buses = Bus.where(start_point: params[:s_point],start_point: @upcase ,start_point: @down1, end_point: params[:e_point], end_point:@upcase2, end_point: @down2 , travel_date: params[:date])
		    elsif params[:s_point].present?
		       @buses = Bus.where('lower(start_point) = ?', params[:s_point].downcase)
		    elsif params[:e_point].present?	
			   @buses = Bus.where('lower(end_point) = ?', params[:e_point].downcase)
		    elsif params[:date].present?
               @buses = Bus.where(travel_date: params[:date])
            end
		    if @buses.empty?
			    flash[:notice] = "no buses are found for ticket booking"
				redirect_to root_path
			end
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
		if params[:no_seats] == "" 
			flash[:notice] = "please enter no.of seats"
			redirect_to book_path(id: params[:bus_id])
			return
		end
		@bus = Bus.find(params[:bus_id])
		if @bus.total_seats < params[:no_seats].to_i
			flash[:notice] = "please enter seats count below #{@bus.total_seats}"
			redirect_to book_path(id: params[:bus_id])
			return
        end
        @reservation = Reservation.new
        @reservation.bus_id = @bus.id
		@available = @bus.total_seats - params[:no_seats].to_i
		@bus.total_seats = @available
		@statement = Statement.new
		@statement.user_id = current_user.id
		@statement.admin_id = @bus.admin_id
		@statement.transaction_type = "debit"
		@statement.amount = @bus.fare * params[:no_seats].to_i
		@statement.ref_id = rand(7 ** 7)
		@payment = Payment.new
		@user = current_user
		@wallet = @user.wallet
		@reservation.user_id = @user.id
		@reservation.no_seats = params[:no_seats].to_i
		@reservation.fare = @statement.amount
		if @statement.amount > @wallet.balance
			flash[:notice] = "insufficient balance, please add money"
			redirect_to new_wallet_path(id: @user.id)
			return
	    end
		@payment.user_id = @user.id
		@cutoff = @wallet.balance - @statement.amount
		@payment.payment_status = "success"
		Wallet.transaction do 
           @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
               @wallet.balance = @cutoff
               @wallet.save
               @statement.remaining_balance = @wallet.balance
               @payment.amount = @statement.amount
               @payment.ref_id = rand(7 ** 7)
               @payment.bus_id = @bus.id
               @payment.save
               @reservation.Reserve_status = "success"
               @reservation.payment_id = @payment.id
               @reservation.save
               UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).confimation_email.deliver_now
               @statement.save
               @bus.save
            end
        end		
	end
end
