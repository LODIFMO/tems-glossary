class ApplicationController < ActionController::Base
  # rescue_from CanCan::AccessDenied do |exception|
  #   redirect_to after_sign_in_path_for(current_user), alert: exception.message
  # end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
