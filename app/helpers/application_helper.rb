module ApplicationHelper

  def full_title(page_title = "")
    base_title = "Task Management System"

    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def check_user_is_admin
    unless current_user.admin
      flash[:alert] = "You are not an Admin. Only Admin has right to login here"
      redirect_to root_path
    end
  end

  def check_user_is_hr
    unless current_user.hr
      flash[:alert] = "You are not an Admin. Only Admin has right to login here"
      redirect_to root_path
    end
  end
end
