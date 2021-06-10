class ReservationController < ApplicationController
	def index	
	end
	def show
		@reservations = Reservation.where(user_id: current_user.id)
		puts @reservations.ids
	end
  def cancel
    @rid = params[:id]
   	@payment = Payment.find(@rid)
    @reservation = Reservation.where(payment_id: @rid).first
  end
  def cancelled
   	@user = current_user
   	@wallet = @user.wallet
   	@reservation = Reservation.find(params[:reservation_id])
    @payment = Payment.find(params[:payment_id])
    if params[:select_seats].to_i > @reservation.no_seats
      flash[:notice] = "plaese select below or equal #{@reservation.no_seats} count"
      redirect_to cancel_path(id: @payment.id)
      return
    end
   	@bus = Bus.find(@reservation.bus_id)
    if params[:select_seats].to_i == @reservation.no_seats
   	  @reservation.Reserve_status = "cancelled"
    else
      @reservation.Reserve_status = "success"
    end
   	@day = @bus.travel_date - Date.today
   	@statement = Statement.new
   	@statement.transaction_type = "credit"
   	@reservation.save
    @fare = @bus.fare * params[:select_seats].to_i 
   	@statement.user_id = @user.id
   	UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).cancel_email.deliver_now
   	if @day < 2
   	  @reservation.fare = @reservation.fare - @fare
      @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
      @reservation.save
   	elsif @day == 3
   	  puts " 3 days "
   	  @refund = Refund.where(days: 3).first
   	  @statement.ref_id = rand(7 ** 7)
   	  @amount = (@fare * @refund.percentage) / 100
   	  @total = @fare - @amount
   	  @statement.refund_amount = @total
   	  @total = @wallet.balance + @total
   	  Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = @total
          @wallet.save
          puts wallet.balance
          @statement.remaining_balance = @wallet.balance
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @reservation.save
          @statement.save
   	      @payment.save
   	    end
   	  end
   	elsif @day > 3 && @day <= 5
   	 	puts " 4 to 5 days"
   	 	@refund = Refund.where(days: 5).first
      @amount = (@fare * @refund.percentage) / 100
      @total = @fare - @amount
   	  @statement.refund_amount = @total
   	  @statement.ref_id = rand(7 ** 7)
   	  @total = @wallet.balance + @total
   	  Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
          @wallet.with_lock do
          @wallet.balance = @total
          @wallet.save
          puts @wallet.balance
          @statement.remaining_balance = @wallet.balance
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @reservation.save
          @statement.save
   	      @payment.save
   	    end
   	  end
   	elsif @day > 5 && @day <= 7
   	 	puts "6 to 7 days"
   	 	@refund = Refund.where(days: 5).first
      @amount = (@fare * @refund.percentage) / 100
      @total = @fare - @amount
   	  @statement.refund_amount = @total
   	  @total = @wallet.balance + @total
   	  @statement.ref_id = rand(7 ** 7)
   	  Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
          @wallet.with_lock do
          @wallet.balance = @total
          @wallet.save
          puts @wallet.balance
          @statement.remaining_balance = @wallet.balance
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @reservation.save
          @statement.save
   	      @payment.save
   	    end
   	  end
   	elsif @day > 7 && @dat < 10
   		puts "8 to 10 days"
   		@refund = Refund.where(days: 7).first
   	  @amount = (@fare * @refund.percentage) / 100
      @total = @fare - @amount
   	  @statement.refund_amount = @total
   	  @total = @wallet.balance + @total
   	  @statement.ref_id = rand(7 ** 7)
   	  Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = @total
          @wallet.save
          puts @wallet.balance
          @statement.remaining_balance = @wallet.balance
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @reservation.save
          @statement.save
   	      @payment.save
   	    end
   	  end
   	elsif @day >= 10
   	  puts "no fee"
   	  @statement.refund_amount = @fare
   	  @statement.ref_id = rand(7 ** 7)
   	  @total = @wallet.balance + @reservation.fare
      Wallet.transaction do 
        @wallet = Wallet.first                                   #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = @total
          @wallet.save
          puts @wallet.balance
          @statement.remaining_balance = @wallet.balance
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_is
          @reservation.save
          @statement.save
   	      @payment.save
   	    end
   	  end	
   	end
  end	
end
