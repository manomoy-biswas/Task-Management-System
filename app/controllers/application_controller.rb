class ApplicationController < ActionController::Base
  include SessionsHelper
  include ApplicationHelper
  before_action :set_cache_headers
  helper_method :current_user
  private
  
  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
