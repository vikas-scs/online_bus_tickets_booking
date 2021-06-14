class WalletController < ApplicationController
	def index
		@user = current_user
	end
	def new
      @user = current_user
      @wallet = @user.wallet
      if params[:bus_id].present?                           #checking whether request from payment page
        @bus = params[:bus_id]
        @due = params[:due]
      end
    end
    def create
      amount = params["balance"].to_f
      if amount < 0                                             #the adding money should be greater then 0 
          flash[:notice] = "invalid amount"
          redirect_to wallets_path
          return
      end
  	  a = current_user.wallet.balance
      total = a + amount
      @user = current_user
      @wallet = @user.wallet         
      @wallet.transaction do                                   #locking the transaction for avoiding deadlocks
        @wallet.with_lock do
          @wallet.balance = total
          if @wallet.save!
            @statement = Statement.new  
            @statement.description = "Adding money to user wallet"                            #creating statement when the user adding money to the wallet
            @statement.transaction_type = "credit"
            @statement.user_id = current_user.id
            @statement.ref_id = "Add#{rand(7 ** 7)}"
            @statement.refund_amount = amount
            @statement.remaining_balance = @wallet.balance
            @statement.save
          end
          @wallet.save
        end
      end
      if params[:bus_id].present?                              #if request from payment stage then redirected to payment page
          redirect_to book_path(:id => params[:bus_id])
          return
      end 
      respond_to do |format|
      if @wallet.save
        format.html { redirect_to wallets_path, notice: "money was added successfully." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_wallet.errors, status: :unprocessable_entity }
      end
    end
  end
end
