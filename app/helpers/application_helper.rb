module ApplicationHelper

  def full_title(page_title = "")
    base_title = "Task Management System"

    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
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
