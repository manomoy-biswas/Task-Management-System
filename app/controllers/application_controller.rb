class ApplicationController < ActionController::Base
  include ApplicationHelper
  include NotificationsHelper
  before_action :set_cache_headers
  helper_method :current_user
  
  def current_user
    if cookies[:auth_token]
      @current_user ||= User.find_by_auth_token(cookies[:auth_token])
    else
      @current_user = nil
    end
  end  

  def check_user_is_admin
    redirect_to overview_path,  flash: { warning: t("application.only_admin") } unless current_user.admin
  end

  def check_user_is_hr
    redirect_to overview_path,  flash: { warning: t("application.only_hr") } unless current_user.hr
  end

  def authenticate_user!
    return if current_user.present? 
    redirect_to root_path, flash: { danger: t("application.authentication_error") }
  end

  private
  
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
