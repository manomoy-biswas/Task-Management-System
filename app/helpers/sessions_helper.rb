module SessionsHelper
  def login(user)
    session[:user_id] = user.id
  end

  def logout
    session[:user_id] = nil
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
