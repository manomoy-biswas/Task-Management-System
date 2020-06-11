class SessionsController < ApplicationController
  before_action :set_user, only: [:create]

  def create
    begin
      user = @user && @user.authenticate(params[:login][:password])
    rescue BCrypt::Errors::InvalidHash
      render "new", flash: { danger: t("session.only_admin") }
      return
    end
    
    if user
      if @user.admin
        login(@user)
        redirect_to user_dashboard_path, flash: { success: t("session.login_success", user: @user.user_name) }
      else
        redirect_to root_path, flash: { warning: t("session.only_admin") }
      end
    else
      render "new", flash: { danger: t("session.invalid_credential") }
    end
  end  
  
  def destroy
    logout
    redirect_to root_path, flash: { success: t("session.logout_success") }
  end

  def new
    return unless logged_in?
    redirect_to admin_login_path, flash: { warning: t("session.logged_in") }
  end  

  private
  def set_user
    @user = User.find_by_email(params[:login][:email])
  end
end
