class ChangePasswordController < ApplicationController
  layout "dashboard"
  include SessionsHelper
  before_action :authenticate_user!, :check_user_is_admin
  before_action :set_user, only: [:create]
  
  def create
    begin
      user = @user && @user.authenticate(params[:password][:old_password])
    rescue BCrypt::Errors::InvalidHash
      render "new", flash: { danger: "Old password doesn't match. Please re enter your old password." }
      return
    end
    if user
      if params[:password][:password] == params[:password][:confirm_password]
        @user.password = params[:password][:password]
        if @user.save
          logout
          redirect_to new_session_path, flash: { success: "Password has been changed. Please login with new password."}
        else
          render "new", flash: {danger: "Something Went Wrong. Please try again"}
        end
      else
        render "new", flash: {danger: "Confirm Password doesn't match."}
      end
    end
  end

  def new
    @password = User.new
  end
  
  private
  def set_user
    @user = User.find(current_user.id)
  end
end
