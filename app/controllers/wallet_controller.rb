class WalletController < ApplicationController
	def index
		@user = current_user
	end
	def new
      @user = current_user
      @wallet = @user.wallet
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
       @user = User.find(current_user.id)
       @wallet = @user.wallet         
       @wallet.transaction do                                   #locking the transaction for avoiding deadlocks
       @wallet.with_lock do
         @wallet.balance = total
         @wallet.save
         @statement.remaining_balance = @wallet.balance
         @statement.save
       end
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
