class WalletController < ApplicationController
	def index
		@user = current_user
	end
	def new
      @user = current_user
      @wallet = @user.wallet
      if params[:bus_id].present?
        @bus = params[:bus_id]
        @due = params[:due]
      end
    end
    def create
    	@statement = Statement.new  
      @statement.description = "Adding money to user wallet"                            #creating statement when the user adding money to the wallet
       @statement.transaction_type = "credit"
       @statement.user_id = current_user.id
       @statement.ref_id = "Add#{rand(7 ** 7)}"
  	   amount = params["balance"].to_f
  	   if amount < 0                                             #the adding money should be greater then 0 
  	    	flash[:notice] = "invalid amount"
  	    	redirect_to wallets_path
  	    	return
  	   end
       @statement.amount = amount
  	   a = current_user.wallet.balance
       total = a + amount
       @user = current_user
       @wallet = @user.wallet         
       @wallet.transaction do                                   #locking the transaction for avoiding deadlocks
       @wallet.with_lock do
         @wallet.balance = total
         if @wallet.save!
            @statement.remaining_balance = @wallet.balance
            @statement.save
          end
        @wallet.save
        if params[:bus_id].present?
          redirect_to book_path(:id => params[:bus_id])
          return
        end
       end
      end
      puts "helloooo"
       
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
