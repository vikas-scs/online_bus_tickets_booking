# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
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
    puts params[:user]
    puts params[:user][:id]
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    if params[:user][:id].present?
      puts "hello00000oooooooooo" 
      redirect_to book_path(id: params[:user][:id])
    else
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
