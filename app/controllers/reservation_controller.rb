class ReservationController < ApplicationController
	def index	
	end
	def show
		@reservations = Reservation.where(user_id: current_user.id, Reserve_status: "success") 
    if @reservations.empty?
        flash[:notice] = "no reservations"
      redirect_to root_path
      return
    end  #getting the all reservations that are associated with user
		puts @reservations.ids
	end
  def cancel
    @rid = params[:id]                                               #getting ticket cancellation id
   	@payment = Payment.find(@rid)
    @reservation = Reservation.where(payment_id: @rid).first
    @bus = Bus.find(@reservation.bus_id)
    @day = @bus.travel_date - Date.today 
    if @day < 3                  #displaying msg that if  travelling date is less then  3 days 
      flash[:notice] = "can't cancel ticket in less then 3 days!!!so plaese enjoy journey"
      redirect_to my_reservations_path
      return
    end
  end
  def cancelled
   	@user = current_user
   	@wallet = @user.wallet
    @admin = Admin.find(1)
   	@reservation = Reservation.find(params[:reservation_id])     #getting the cancellation ticket reservation_id
    @state = Statement.where(reservation_id: params[:reservation_id]).first
    @payment = Payment.find(params[:payment_id])
    if params[:select_seats].to_i > @reservation.no_seats         #checking whether the cancellation ticket count exceeds the booking ticket count
      flash[:notice] = "plaese select below or equal #{@reservation.no_seats} count"
      redirect_to cancel_path(id: @payment.id)
      return
    end
   	@bus = Bus.find(@reservation.bus_id)
    @admin = Admin.find(1)
    if params[:select_seats].to_i <= 0
      puts "cominggg"                                 #checking whether the no.of tickets are entered or empty
      flash[:notice] = "please enter no.of seats"
       redirect_to cancel_path(id: @payment.id)
      return
    end
    if params[:select_seats] == ""                               #checking whether the no.of tickets are entered or empty
      flash[:notice] = "please enter no.of seats"
       redirect_to cancel_path(id: @payment.id)
      return
    end               
    if params[:select_seats].to_i == @reservation.no_seats          #checking the whether all tickets are cancelled 
   	  @reservation.Reserve_status = "cancelled"
    else
      @reservation.Reserve_status = "success"
    end
   	@day = @bus.travel_date - Date.today                            #getting day to travelling day gap
   	@statement = Statement.new                                       #creating a statement for adding refund amount to user
    @statement.bus_id = @bus.id
   	@statement.transaction_type = "credit"
    @fare = @state.seat_fare * params[:select_seats].to_i 
   	@statement.user_id = @user.id
    @statement.description = "Adding refund to user"
    @statement.no_seats = params[:select_seats].to_i
    @statement.seat_fare = @state.seat_fare
    @statement.user_id = @user.id
    @statement.ref_id = "ref#{rand(7 ** 7)}"
    @cancel_fee = CancelFee.find(1)                            #getting the cancellation percentage for refund money
    @statement1 = Statement.new                                #getting the debit info from admin as a statement
    @statement1.bus_id = @bus.id
    @statement1.transaction_type = "debit"
    @statement1.description = "Giving refund amount to user"
    @statement1.no_seats = params[:select_seats].to_i
    @statement1.seat_fare = @state.seat_fare
    @statement1.admin_id = @admin.id
    @statement1.ref_id = "ref#{rand(7 ** 7)}"
    if @day <= 10                                            #conditions for cutting refund money based on days gap
      if @day == 3
   	    @amount = (@fare * @cancel_fee.hrs_72) / 100 
     	elsif @day > 3 && @day <= 5
        @amount = (@fare * @cancel_fee.days_5) / 100
   	  elsif @day > 5 && @day <= 7
        @amount = (@fare * @cancel_fee.days_7) / 100
   	  elsif @day > 7 && @day <= 10
   	    @amount = (@fare * @cancel_fee.days_10) / 100
      end
      @refunds = @fare - @amount
      @statement.refund_amount = @refunds
   	  @statement1.refund_amount = @refunds
   	  @user_get = @wallet.balance + @refunds
   	  @wallet.transaction do                                    #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = @user_get
          if @wallet.save!
            @statement.remaining_balance = @wallet.balance 
          end
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @bus.available_seats = @bus.available_seats + params[:select_seats].to_i
          @reservation.save
   	      @payment.save
          @statement.reservation_id = @reservation.id
          @statement1.reservation_id = @reservation.id
          @statement.save
          @bus.save
   	    end
   	  end
      @admin.transaction do                                    #locking the transaction for avoiding deadlocks
        @admin.with_lock do
          @charge =  @admin.wallet  - @amount 
          @admin.wallet = @charge
          if @admin.save!
            @statement1.remaining_balance = @admin.wallet
            @statement1.save
            flash[:notice] = "successfully cancelled ticket!!!"
            redirect_to my_reservations_path
          end
        end
      end
   	elsif @day > 10
   	  @statement.refund_amount = @fare
      @get = @wallet.balance + @fare
      @statement1.refund_amount = @fare
      @admin_get = @admin.wallet - @fare
      @bus.available_seats = @bus.available_seats + params[:select_seats].to_i
      @wallet.transaction do                                    #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = @get
          if @wallet.save!
            @statement.remaining_balance = @wallet.balance
          end
          @reservation.fare = @reservation.fare - @fare
          @reservation.no_seats = @reservation.no_seats - params[:select_seats].to_i
          @bus.available_seats = @bus.available_seats + params[:select_seats].to_i
          @reservation.save
          @statement.save
   	      @payment.save
          @statement.reservation_id = @reservation.id
          @statement1.reservation_id = @reservation.id
          @statement.save
          @bus.save
   	    end
   	  end
      @admin.transaction do                                    #locking the transaction for avoiding deadlocks
        @admin.with_lock do
          @admin.wallet = @admin_get
          if @admin.save!
            @statement1.remaining_balance = @admin.wallet
            @statement1.save
            flash[:notice] = "successfully cancelled ticket!!!"
            redirect_to my_reservations_path
          end
        end
      end
   	end
    UserMailer.with(user_id: @user.id, reservation_id: @reservation.id).cancel_email.deliver_now  
  end	
end
