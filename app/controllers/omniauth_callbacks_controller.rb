class OmniauthCallbacksController < ApplicationController
  include SessionsHelper
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      unless @user.admin
        login(@user)
        flash[:success] = I18n.t "omniauth_callbacks.success"
        redirect_to root_path
      else
        redirect_to root_path
        flash[:danger] = I18n.t "omniauth_callbacks.failed"
      end
    else
      redirect_to root_path
      flash[:danger] = I18n.t "omniauth_callbacks.faild"
    end
  end
end
