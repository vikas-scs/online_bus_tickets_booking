class UserMailer < ApplicationMailer
	default from: 'notifications@example.com'

  def confimation_email
    @user = User.find(params[:user_id])
    @reservation = Reservation.find(params[:reservation_id])
    mail(to: @user.email, subject: 'ticket confirmation')
  end
  def cancel_email
    @user = User.find(params[:user_id])
    @reservation = Reservation.find(params[:reservation_id])
    mail(to: @user.email, subject: 'cancel confirmation')
  end
end
