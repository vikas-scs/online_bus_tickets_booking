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
		    	@buses = Bus.where('lower(start_point) LIKE lower(?) AND lower(end_point) LIKE lower(?) AND Date(travel_date) = ? AND status = ? AND available_seats != ? AND travel_date > ?', "%#{params[:s_point]}%", "%#{params[:e_point]}%",params[:date], "1", 0, Date.today)
		    	
		    elsif params[:s_point].present? && params[:e_point].present?
		       	
		       @buses = Bus.where('lower(start_point) LIKE lower(?) AND lower(end_point) LIKE lower(?) AND status = ? AND available_seats != ? AND travel_date > ?', "%#{params[:s_point]}%", "%#{params[:e_point]}%", "1", 0,Date.today)
		    elsif params[:s_point].present? && params[:date].present?
		       @buses = Bus.where('lower(start_point) = ? AND Date(travel_date) = ? AND status = ? AND available_seats != ? AND travel_date > ?', params[:s_point].downcase,params[:date], "1",0,Date.today)
		       
		    elsif params[:e_point].present?	&& params[:date].present?
			   @buses = Bus.where('lower(end_point) = ? AND Date(travel_date) = ? AND status = ? AND available_seats != ? AND travel_date > ?', params[:e_point].downcase,params[:date], "1",0,Date.today)
			elsif params[:s_point].present?	
			   @buses = Bus.where('lower(start_point) = ? AND status = ? AND available_seats != ? AND travel_date > ?', params[:s_point].downcase, "1",0,Date.today)
			   elsif params[:e_point].present?	
			   @buses = Bus.where('lower(end_point) = ? AND status = ? AND available_seats != ? AND travel_date > ?', params[:e_point].downcase, "1", 0,Data.today)
			   
		    elsif params[:date].present?
               @buses = Bus.where('Date(travel_date) = ? AND status = ? AND available_seats != ? AND travel_date > ?',params[:date],"1",0,Date.today)
            end 
            puts @buses.ids                                       
		    if @buses.empty?                                    #if searching result is not found then display the error message
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
		@seats = Bus.find(params[:id])	
		if @seats.available_seats <= 0 
		    flash[:notice] = "no seats are available"
			redirect_to root_path
        end                        #getting the details the booking bus	
	end
	def seats
		
		@bus = Bus.find(params[:bus_id])
		puts params.inspect
		if params[:no_seats].to_i <= 0
		  puts "cominggg"                                 #checking whether the no.of tickets are entered or empty
			flash[:notice] = "please enter no.of seats"
			redirect_to book_path(id: params[:bus_id])
			return
		end
		if params[:no_seats] == ""                               #checking whether the no.of tickets are entered or empty
			flash[:notice] = "please enter no.of seats"
			redirect_to book_path(id: params[:bus_id])
			return
		end                            #checking bus date that if already travelling completed
		if @bus.travel_date < Date.today
			flash[:notice] = "bus is outdated plaese select another one"
			redirect_to book_path(id: params[:bus_id])
		    return
		end   
		if @bus.available_seats < params[:no_seats].to_i              #checking whether the required seats are exceeds the bus capacity          
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
		@payment = Payment.new                                #creating a payment note for booking ticket
		@reservation.user_id = @user.id
		@reservation.no_seats = params[:no_seats].to_i
		@payment.user_id = @user.id
		@cutoff = @wallet.balance - @cost
		@payment.payment_status = "success"
		@wallet.transaction do                                    #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
               @wallet.balance = @cutoff
               if @wallet.save!
               	@statement = Statement.new
               	@statement.bus_id = @bus.id
		         @statement.user_id = current_user.id
		         @statement.transaction_type = "debit"
		         @statement.amount = @cost
		         @statement.ref_id = "res#{rand(7 ** 7)}"  
		         @reservation.bus_no = "AP #{rand(7*3)} #{rand(7*8*7*8)}"                                 #creating a statement for cutting the money from user to book the tickets
                  @statement.remaining_balance = @wallet.balance
                  @statement.description = "Booking tickets"
	             @statement.no_seats = params[:no_seats].to_i
	             @statement.seat_fare = @bus.fare
                  @payment.amount = @statement.amount
                  @reservation.fare = @statement.amount
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
        end
        @admin.transaction do 
           @admin.with_lock do 
                @add = @admin.wallet + @statement.amount
                @admin.wallet = @add
                if @admin.save!
                	 @statement1 = Statement.new                            #creating a statement for adding the cutting amount to admin wallet
                     @statement1.bus_id = @bus.id
                     @statement1.admin_id = @admin.id
                     @statement1.transaction_type = "credit"
                     @statement1.amount = @bus.fare * params[:no_seats].to_i
                     @statement1.ref_id = "res#{rand(7 ** 7)}"
                     @statement1.description = "getting money for Booking tickets"
                     @statement1.no_seats = params[:no_seats].to_i
                     @statement1.seat_fare = @bus.fare
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
	end
	def statement
		@reservation = Reservation.find(params[:id])
		@statement1 =   Statement.where( user_id: current_user.id,reservation_id: @reservation.id)
		@statement = @statement1.order("created_at DESC")
		puts @statement.ids
		 if @statement.empty?                                    #if searching result is not found then display the error message
			    flash[:notice] = "no statements found"
				redirect_to root_path
			end
		puts @statement     #getting all the statements that are connected with reservation id
	end
	def statements
		@statement1 =   Statement.where(user_id: current_user.id)
		@statement = @statement1.order("created_at DESC")
		if @statement.empty?                                  #if searching result is not found then display the error message
			    flash[:notice] = "no statements found"
				redirect_to root_path
		end                           #getting all the statements that are associated with the user_id
	end
	def buses
		@buses = Bus.where(status: "1")
		if @buses.empty?                                    #if searching result is not found then display the error message
			    flash[:notice] = "no statements found"
				redirect_to root_path
			end                                        #displaying the all available buses
		puts @buses
	end
end
