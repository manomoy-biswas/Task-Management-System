class SessionsController < ApplicationController
  include SessionsHelper

  before_action :find_user, only: [:create]
  def new
    unless logged_in?
      return
    else
      flash[:warning] = "You have already logged in."
      if admin?
        redirect_to admin_dashboard_path
      else
        redirect_to root_path
      end
    end
  end  

  def create
    if @user && @user.authenticate(params[:login][:password])
      if @user.admin
        login(@user)
        flash[:success] = "Successfully Loged in."
        redirect_to admin_dashboard_path
      else
        flash[:warning] = "Only Admin can login here. Youare not a Admin"
        redirect_to root_path
      end
    else
      flash[:danger] = "Email or password is invalid"
      render "new"
    end
  end  

  def destroy
    logout
    flash[:success] = "Successfully Loged out."
    redirect_to root_path
  end

  private
  def find_user
    @user = User.find_by_email(params[:login][:email])
  end
end
