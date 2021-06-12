class BusController < ApplicationController
	def index
		
	end
	def search
		puts params.inspect
		if !params[:s_point].present? && !params[:e_point].present? && !params[:date].present?
            	flash[:notice] = "please enter any details"
				redirect_to root_path
		else
		    if params[:s_point].present? && params[:e_point].present? && params[:date].present?
		    	@buses = Bus.where(start_point: params[:s_point], end_point: params[:e_point], travel_date: params[:date])
		    elsif params[:s_point].present? && params[:e_point].present?	
		       @buses = Bus.where('lower(start_point) LIKE lower(?) AND lower(end_point) LIKE lower(?)', "%#{params[:s_point]}%", "%#{params[:e_point]}%")
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
		if @bus.travel_date < Date.today
			flash[:notice] = "bus is outdated plaese select another one"
			redirect_to book_path(id: params[:bus_id])
		    return
		end
		if @bus.total_seats < params[:no_seats].to_i
			flash[:notice] = "please enter seats count below #{@bus.total_seats}"
			redirect_to book_path(id: params[:bus_id])
			return
        end
        @admin = Admin.find(1)
        @reservation = Reservation.new
        @reservation.bus_id = @bus.id
		@available = @bus.total_seats - params[:no_seats].to_i
		@bus.available_seats = @available
		@statement = Statement.new
		@statement1 = Statement.new
		@statement.bus_id = @bus.id
		@statement1.bus_id = @bus.id
		@statement.user_id = current_user.id
		@statement1.user_id = current_user.id
		@statement.admin_id = @admin.id
		@statement1.admin_id = @admin.id
		@statement.transaction_type = "debit"
		@statement1.transaction_type = "credit"
		@statement.amount = @bus.fare * params[:no_seats].to_i
		@statement1.amount = @bus.fare * params[:no_seats].to_i
		@user = current_user
		@wallet = @user.wallet
		if @statement.amount > @wallet.balance
			flash[:notice] = "insufficient balance, please add money"
			redirect_to new_wallet_path(id: @user.id)
			return
	    end
		@statement.ref_id = "res#{rand(7 ** 7)}"
		@statement1.ref_id = "res#{rand(7 ** 7)}"
		@payment = Payment.new
		@reservation.user_id = @user.id
		@reservation.no_seats = params[:no_seats].to_i
		@reservation.fare = @statement.amount
	    @statement.description = "Booking tickets"
	    @statement1.description = "getting money for Booking tickets"
	    @statement.no_seats = params[:no_seats].to_i
	    @statement1.no_seats = params[:no_seats].to_i
	    @statement.seat_fare = @bus.fare
	    @statement1.seat_fare = @bus.fare
		@payment.user_id = @user.id
		@cutoff = @wallet.balance - @statement.amount
		@payment.payment_status = "success"
		@wallet.transaction do                                    #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
               @wallet.balance = @cutoff
               @wallet.save
               @statement.remaining_balance = @wallet.balance
               @payment.amount = @statement.amount
               @payment.ref_id = "res#{rand(7 ** 7)}"
               @payment.bus_id = @bus.id
               @payment.save
               @reservation.Reserve_status = "success"
               @reservation.payment_id = @payment.id
               @reservation.save
               @statement.reservation_id = @reservation.id
               UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).confimation_email.deliver_now
               @statement.save
               @bus.save
            end
        end
        @admin.transaction do 
           @admin.with_lock do 
              @add = @admin.wallet + @statement.amount
              @admin.wallet = @add
              @admin.save
                 @statement1.remaining_balance = @admin.wallet
                 @statement1.reservation_id = @reservation.id
                 if @statement1.save
                   flash[:notice] = "booking successful"
			       redirect_to my_reservations_path
			     return
			  end
			end
	    end	
	end
	def statement
		@reservation = Reservation.find(params[:id])
		@statement = @reservation.statements
	end
	def statements
		@user = current_user
		@statements = @user.statements
		
	end
end
