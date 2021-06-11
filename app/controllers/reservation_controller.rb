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
    @admin = Admin.find(1)
   	@reservation = Reservation.find(params[:reservation_id])
    @payment = Payment.find(params[:payment_id])
    if params[:select_seats].to_i > @reservation.no_seats
      flash[:notice] = "plaese select below or equal #{@reservation.no_seats} count"
      redirect_to cancel_path(id: @payment.id)
      return
    end
   	@bus = Bus.find(@reservation.bus_id)
    @admin = Admin.find(1)
    if params[:select_seats].to_i == @reservation.no_seats
   	  @reservation.Reserve_status = "cancelled"
    else
      @reservation.Reserve_status = "success"
    end
   	@day = @bus.travel_date - Date.today
   	@statement = Statement.new
    @statement1 = Statement.new
   	@statement.transaction_type = "credit"
    @statement1.transaction_type = "credit"
    @fare = @bus.fare * params[:select_seats].to_i 
   	@statement.user_id = @user.id
    @statement.admin_id = @admin.id
    @statement1.user_id = @user.id
    @statement1.admin_id = @admin.id
    @statement.ref_id = "ref#{rand(7 ** 7)}"
    @statement1.ref_id = "fee#{rand(7 ** 7)}"
    @cancel_fee = CancelFee.find(1)
   	if @day < 3
      flash[:notice] = "can't cancel ticket in less then 3 days!!!so plaese enjoy journey"
      redirect_to my_reservations_path
      return
   	end
    if @day <= 10
    if @day == 3
   	  @amount = (@fare * @cancel_fee.hrs_72) / 100 
   	elsif @day > 3 && @day <= 5
      @amount = (@fare * @cancel_fee.days_5) / 100
   	elsif @day > 5 && @day <= 7
      @amount = (@fare * @cancel_fee.days_7) / 100
   	elsif @day > 7 && @dat <= 10
   	  @amount = (@fare * @cancel_fee.days_10) / 100
    end
      @statement1.refund_amount = @amount
      @admin.transaction do 
        @admin = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @admin.email )                                   #locking the transaction for avoiding deadlocks
        @admin.with_lock do
          @charge = @amount + @admin.wallet
          @admin.wallet = @charge
          if @admin.save!
            @statement1.remaining_balance = @admin.wallet
            @statement1.save
          end
        end
      end
      @total = @fare - @amount
   	  @statement.refund_amount = @total
   	  @total = @wallet.balance + @total
   	  @wallet.transaction do 
        @wallet = Wallet.lock("FOR UPDATE NOWAIT").find_by(user_id: @wallet.user_id )                                   #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = @total
          if @wallet.save!
            @statement.remaining_balance = @wallet.balance
            @statement.save
          end
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @reservation.save
   	      @payment.save
          @reservation.save
   	    end
   	  end
   	  elsif @day > 10
   	  puts "no fee"
   	  @statement.refund_amount = @fare
   	  @total = @wallet.balance + @reservation.fare
      @statement1.refund_amount = 0
      @wallet.transaction do 
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
          @statement1.remaining_balance = @admin.wallet
          @statement1.save
   	      @payment.save
          @reservation.save
   	    end
   	  end
   	end
          UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).cancel_email.deliver_now  
  end	
end
