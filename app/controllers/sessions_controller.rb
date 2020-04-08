class SessionsController < ApplicationController
  include SessionsHelper
  before_action :find_user, only: [:create]

  def new
    unless logged_in?
      return
    else
      flash[:warning] = I18n.t "session.logged_in"
      redirect_to admin_login_path
    end
  end  

  def create
    begin
      user = @user && @user.authenticate(params[:login][:password])
    rescue BCrypt::Errors::InvalidHash
      flash[:danger] = I18n.t "session.only_admin"
      render "new"
      return
    end
    
    if user
      if @user.admin
        login(@user)
        flash[:success] = I18n.t "session.login_success", user: @user.user_name
        redirect_to user_dashboard_path
      else
        flash[:warning] = I18n.t "session.only_admin"
        redirect_to root_path
      end
    else
     flash[:danger] = I18n.t "session.invalid_credential"
      render "new"
    end
  end  

  def destroy
    logout
    flash[:success] = I18n.t "session.logout_success"
    redirect_to root_path
  end

  private
  def find_user
    @user = User.find_by_email(params[:login][:email])
  end
end
