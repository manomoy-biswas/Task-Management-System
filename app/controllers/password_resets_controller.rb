class PasswordResetsController < ApplicationController
  before_action :set_users, only: [:create]

  def create
    return redirect_to root_path, flash: {warning: "You are not an admin. Please login via google account."} unless @user.admin
    @user.send_password_reset if @user
    redirect_to root_path, :notice => "Email sent with password reset instructions."
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 3.hours.ago
      redirect_to new_password_reset_path, flash: {danger: "Password reset has expired." }
    elsif @user.update(params_password)
      redirect_to root_url, flash: { success: "Password has been reset!" }
    else
      render "edit"
    end
  end
  private
   
  def set_users
    @user = User.find_by_email(params[:email])
  end
  def params_password
    params.require(:user).permit(:password, :password_confirmation)
  end
end
