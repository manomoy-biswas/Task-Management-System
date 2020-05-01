module SessionsHelper
  def login(user)
    session[:user_id] = user.id
  end

  def logout
    session[:user_id] = nil
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def authenticate_user!
    return if logged_in?
    flash[:danger] = I18n.t "application.authentication_error"
    redirect_to root_path
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    current_user.admin
  end

  def hr?
    current_user.hr
  end
end
