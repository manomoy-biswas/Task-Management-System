class ApplicationController < ActionController::Base
  before_action :set_cache_headers
  helper_method :current_user
  
  def current_user
    if session[:user_id]
      current_user ||= User.find(session[:user_id])
    else
      current_user = nil
    end
  end

  def authenticate_user!
    return if current_user.present?

    flash[:danger] = "Please login with your credential."
    redirect_to root_path
  end

  private
  
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
