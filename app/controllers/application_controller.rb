class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
    helper_method :current_user

  def authorize
    redirect_to root_url, alert: "not authorized" if current_user.nil?
  end

  def current_user_root
    if current_user.role == 'admin'
      # implement
    else
      user_path(current_user)
    end
  end
end
