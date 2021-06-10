class ApplicationController < ActionController::Base
	 before_action :configure_permitted_parameters, if: :devise_controller?
   def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :mobile, :last_name])  
  end
  def after_sign_in_path_for(resource)
    case resource.class.to_s
    when "User"
      puts "heeeeeeee" 
      root_path
    when "Admin"
      puts "hello"
    	rails_admin_path
      # new_admin_session_path
    end
  end
end
