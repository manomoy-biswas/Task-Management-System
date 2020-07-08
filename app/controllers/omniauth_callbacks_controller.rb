class OmniauthCallbacksController < ApplicationController
  include SessionsHelper
  
  def google_oauth2
    begin
      @user = User.from_omniauth(request.env["omniauth.auth"])
      if @user.persisted?
        unless @user.admin
          login(@user)
          redirect_to users_dashboard_path, flash: { success: t("omniauth_callbacks.success") }
        end
      else
        redirect_to root_path, flash: { danger: t("omniauth_callbacks.failed") }
      end
    rescue
      logout if current_user.present?
      return redirect_to root_path, flash: { danger: t("omniauth_callbacks.error") }
    end
  end
end
