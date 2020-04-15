class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApplicationHelper
  before_action :set_cache_headers
  helper_method :current_user
  before_action :notify

  def notify
    @notification = Notification.where(recipient: current_user)
  end
  
  def current_user
    if session[:user_id]
      current_user ||= User.find(session[:user_id])
    else
      current_user = nil
    end
  end

  def authenticate_user!
    return if logged_in?
    flash[:danger] = I18n.t "application.authentication_error"
    redirect_to root_path
  end

  private
  
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
