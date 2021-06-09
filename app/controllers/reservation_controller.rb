class ReservationController < ApplicationController
	def index
		puts params.inspect
		@bus = Bus.find(params[:bus_id])
		@reservation = Reservation.new
		@user = current_user
		@reservation.bus_id = params[:bus_id]
		@reservation.user_id = @user.id
		@reservation.seat_no = rand(1..35)
		@reservation.fare = @bus.fare
		@reservation.admin_id = @bus.admin_id
		@reservation.Reserve_status = "pending"
		@reservation.save		
	end
	def show
		puts params.inspect
		@reservations = Reservation.where(user_id: current_user.id)
		puts @reservations.ids
	end
	def payment
		puts params.inspect
		@reservation = Reservation.find(params[:id])
		@bus = Bus.find(@reservation.bus_id)
		@available = @bus.total_seats - 1
		@bus.total_seats = @available
		@statement = Statement.new
		@statement.user_id = current_user.id
		@statement.transaction_type = "debit"
		@statement.amount = @reservation.fare
		@statement.ref_id = rand(7 ** 7)
		@payment = Payment.new
		@user = current_user
		@wallet = @user.wallet
		if @reservation.fare > @wallet.balance
			flash[:notice] = "insufficient balance, please add money"
			redirect_to new_wallet_path(id: @user.id)
			return
	    end
		@payment.user_id = @user.id
		@payment.reservation_id = @reservation.id
		@cutoff = @wallet.balance - @reservation.fare
		@payment.payment_status = "success"
		Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
         @wallet.balance = @cutoff
         @wallet.save
         @statement.remaining_balance = @wallet.balance
         @payment.amount = @reservation.fare
         @payment.ref_id = rand(7 ** 7)
         @payment.bus_id = @reservation.bus_id
         @reservation.Reserve_status = "success"
        
         @reservation.save
         @payment.save
         UserMailer.with(user_id: @user.id, payment_id: @payment.id).confimation_email.deliver_now
         @statement.save
         @bus.save
         end
       end
   end
   def cancel
   	   @rid = params[:id]
   	   @payment = Payment.where(reservation_id: @rid).first
   end
   def cancelled
   	  @user = current_user
   	  @wallet = @user.wallet
   	  @reservation = Reservation.find(params[:reservation_id])
   	  @payment = Payment.find(params[:payment_id])
   	  @bus = Bus.find(@reservation.bus_id)
   	  @reservation.Reserve_status = "cancelled"
   	  @day = @bus.travel_date - Date.today
   	  puts @day
   	  @statement = Statement.new
   	  @statement.transaction_type = "credit"
   	  @reservation.save
   	  @statement.user_id = @user.id
   	  @payment.payment_status = "refunded"
   	  UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).cancel_email.deliver_now
   	  if @day < 2
   	    @payment.save
   	  elsif @day == 3
   	  	puts " 3 days "
   	  	@refund = Refund.where(days: 3).first
   	  	@statement.ref_id = rand(7 ** 7)
   	  	@amount = (@reservation.fare * @refund.percentage) / 100
   	  	@total = @reservation.fare - @amount
   	  	@statement.refund_amount = @total

   	  	Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
             @wallet.balance = @total
            @wallet.save
            puts wallet.balance
            @statement.remaining_balance = @wallet.balance
            @statement.save
   	        @payment.save
   	       end
   	    end
   	 elsif @day > 3 && @day <= 5
   	 	puts " 4 to 5 days"
   	 	@refund = Refund.where(days: 5).first
        @amount = (@reservation.fare * @refund.percentage) / 100
   	  	@total = @reservation.fare - @amount
   	  	@statement.refund_amount = @total
   	  	@statement.ref_id = rand(7 ** 7)
   	  	Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
             @wallet.balance = @total
            @wallet.save
            puts @wallet.balance
            @statement.remaining_balance = @wallet.balance
            @statement.save
   	        @payment.save
   	       end
   	    end
   	 elsif @day > 5 && @day <= 7
   	 	puts "6 to 7 days"
   	 	@refund = Refund.where(days: 5).first
        @amount = (@reservation.fare * @refund.percentage) / 100
   	  	@total = @reservation.fare - @amount
   	  	@statement.refund_amount = @total
   	  	@statement.ref_id = rand(7 ** 7)
   	  	Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
             @wallet.balance = @total
            @wallet.save
            puts @wallet.balance
            @statement.remaining_balance = @wallet.balance
            @statement.save
   	        @payment.save
   	       end
   	    end
   	elsif @day > 7 && @dat < 10
   		puts "8 to 10 days"
   		@refund = Refund.where(days: 7).first
   	    @amount = (@reservation.fare * @refund.percentage) / 100
   	  	@total = @reservation.fare - @amount
   	  	@statement.refund_amount = @total
   	  	@statement.ref_id = rand(7 ** 7)
   	  	Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
             @wallet.balance = @total
            @wallet.save
            puts @wallet.balance
            @statement.remaining_balance = @wallet.balance
            @statement.save
   	        @payment.save
   	       end
   	    end
   	    elsif @day >= 10
   	    	puts "no fee"
   	    	@statement.refund_amount = @reservation.fare
   	    	@statement.ref_id = rand(7 ** 7)
   	    	@total = @wallet.balance + @reservation.fare
          Wallet.transaction do 
           @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
           @wallet.with_lock do
            @wallet.balance = @total
            @wallet.save
            puts @wallet.balance
            @statement.remaining_balance = @wallet.balance
            @statement.save
   	        @payment.save
   	       end
   	    end	
   	 end
   	end	
end
