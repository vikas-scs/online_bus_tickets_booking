class BusController < ApplicationController
	def index
		
	end
	def search
		puts params.inspect                                               #checking whether all field are empty
		if !params[:s_point].present? && !params[:e_point].present? && !params[:date].present?
            	flash[:notice] = "please enter any details"
				redirect_to root_path
		else                                                               #checking whether the how many inputs are given
		    if params[:s_point].present? && params[:e_point].present? && params[:date].present?
		    	@buses = Bus.where('lower(start_point) LIKE lower(?) AND lower(end_point) LIKE lower(?) AND Date(travel_date) = ? AND status = ? ', "%#{params[:s_point]}%", "%#{params[:e_point]}%",params[:date], "1")
		    	@rem_buses = Bus.where('lower(start_point) LIKE lower(?) AND lower(end_point) LIKE lower(?) AND status = ? ', "%#{params[:s_point]}%", "%#{params[:e_point]}%", "1")
		    elsif params[:s_point].present? && params[:e_point].present?
		       @rem_buses = []	
		       @buses = Bus.where('lower(start_point) LIKE lower(?) AND lower(end_point) LIKE lower(?) AND status = ?', "%#{params[:s_point]}%", "%#{params[:e_point]}%", "1")
		    elsif params[:s_point].present?
		       @buses = Bus.where('lower(start_point) = ? AND status = ?', params[:s_point].downcase, "1")
		       @rem_buses = []	
		    elsif params[:e_point].present?	
			   @buses = Bus.where('lower(end_point) = ? AND status = ?', params[:e_point].downcase, "1")
			   @rem_buses = []	
		    elsif params[:date].present?
               @buses = Bus.where(travel_date: params[:date], status: "1")
               @rem_buses = []	
            end                                         
		    if @buses.empty? && @rem_buses.empty                                    #if searching result is not found then display the error message
			    flash[:notice] = "no buses are found for ticket booking"
				redirect_to root_path
			end
		end
	end
	def book
		if !user_signed_in?                                      #checking whether user is logged in or not before booking tickets
			flash[:notice] = "please login to continue"
			redirect_to new_user_session_path(id: params[:id])
		end
		@seats = Bus.find(params[:id])	                          #getting the details the booking bus	
	end
	def seats
		if params[:no_seats] == ""                                 #checking whether the no.of tickets are entered or empty
			flash[:notice] = "please enter no.of seats"
			redirect_to book_path(id: params[:bus_id])
			return
		end
		@bus = Bus.find(params[:bus_id])                            #checking bus date that if already travelling completed
		if @bus.travel_date < Date.today
			flash[:notice] = "bus is outdated plaese select another one"
			redirect_to book_path(id: params[:bus_id])
		    return
		end   
		if @bus.available_seats < params[:no_seats].to_i                #checking whether the required seats are exceeds the bus capacity          
			flash[:notice] = "please enter seats count below #{@bus.available_seats}"
			redirect_to book_path(id: params[:bus_id])
			return
        end
        @user = current_user
		@wallet = @user.wallet
        @cost = @bus.fare * params[:no_seats].to_i                  #checking whether the required amount is available in user wallet
        if @cost > @wallet.balance
			@yes = @cost - @wallet.balance
			flash[:notice] = "insufficient balance, please add money"
			redirect_to new_wallet_path(id: @user.id,bus_id: @bus.id,due: @yes)
			return
	    end
	    if @bus.available_seats < 0
			flash[:notice] = "bus is full plaese select another one"
			redirect_to book_path(id: params[:bus_id])
			return
	    end
        @admin = Admin.find(1)
        @reservation = Reservation.new
        @reservation.bus_id = @bus.id
		@available = @bus.available_seats - params[:no_seats].to_i
		@bus.available_seats = @available
		@statement = Statement.new                                   #creating a statement for cutting the money from user to book the tickets
		@statement.bus_id = @bus.id
		@statement.user_id = current_user.id
		@statement.admin_id = @admin.id
		@statement.transaction_type = "debit"
		@statement.amount = @cost
		@statement.ref_id = "res#{rand(7 ** 7)}"
		@payment = Payment.new                                #creating a payment note for booking ticket
		@reservation.user_id = @user.id
		@reservation.no_seats = params[:no_seats].to_i
		@reservation.fare = @statement.amount
	    @statement.description = "Booking tickets"
	    @statement.no_seats = params[:no_seats].to_i
	    @statement.seat_fare = @bus.fare
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
               UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).confimation_email.deliver_now     #sending the confirmation email to user for ticket booking details
               @statement.save
               @bus.save
            end
        end
        @statement1 = Statement.new                            #creating a statement for adding the cutting amount to admin wallet
        @statement1.bus_id = @bus.id
        @statement1.user_id = current_user.id
        @statement1.admin_id = @admin.id
        @statement1.transaction_type = "credit"
        @statement1.amount = @bus.fare * params[:no_seats].to_i
        @statement1.ref_id = "res#{rand(7 ** 7)}"
        @statement1.description = "getting money for Booking tickets"
        @statement1.no_seats = params[:no_seats].to_i
        @statement1.seat_fare = @bus.fare
        @admin.transaction do 
           @admin.with_lock do 
                @add = @admin.wallet + @statement.amount
                @admin.wallet = @add
                @admin.save
                @statement1.remaining_balance = @admin.wallet
                @statement1.reservation_id = @reservation.id
                if @statement1.save                                        #displaying success message if the booking id succesful
                    flash[:notice] = "booking successful"
			        redirect_to my_reservations_path
			        return
			    end
			end
	    end	
	end
	def statement
		@reservation = Reservation.find(params[:id])
		@statement =   Statement.where(reservation_id: @reservation.id, description: "Adding refund to user")
		puts @statement     #getting all the statements that are connected with reservation id
	end
	def statements
		@user = current_user
		@statements = @user.statements                           #getting all the statements that are associated with the user_id
	end
	def buses
		@buses = Bus.all                                         #displaying the all available buses
		puts @buses
	end
end
