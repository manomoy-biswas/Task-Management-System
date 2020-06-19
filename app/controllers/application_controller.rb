class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApplicationHelper
  before_action :set_cache_headers
  helper_method :current_user
  
  protected
  def check_user_is_admin
    redirect_to root_path,  flash: { warning: t("application.only_admin") } unless admin?
  end

  def check_user_is_hr
    redirect_to users_dashboard_path,  flash: { warning: t("application.only_hr") } if hr?
  end

  def authenticate_user!
    return if logged_in? 
    redirect_to root_path, flash: { danger: t("application.authentication_error") }
  end

  private
  
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
