# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    puts params.inspect
    puts params[:id]
    puts "hello"
    if params[:id].present?
      @id = params[:id]
    end
    super

  end

  # POST /resource/sign_in
  def create
    puts params[:id]
    if params[:id].present?
      redirect_to book_path(id: params[:id])
    else
     super
   end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
