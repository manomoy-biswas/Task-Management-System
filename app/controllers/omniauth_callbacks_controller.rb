class OmniauthCallbacksController < ApplicationController
  include SessionsHelper
  def google_oauth2
    begin
      @user = User.from_omniauth(request.env["omniauth.auth"])
      if @user.persisted?
        unless @user.admin
          login(@user)
          flash[:success] = I18n.t "omniauth_callbacks.success"
          redirect_to users_dashboard_path
        end
      else
        redirect_to root_path
        flash[:danger] = I18n.t "omniauth_callbacks.failed"
      end
    rescue
      if logged_in?
        logout
      end
      redirect_to root_path
      flash[:danger] = I18n.t "omniauth_callbacks.error"
      return
    end
  end
end
