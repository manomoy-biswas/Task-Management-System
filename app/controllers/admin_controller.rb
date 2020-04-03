class AdminController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!, :check_user_is_admin
  def dashboard
  end
end
