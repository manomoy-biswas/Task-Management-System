module ApplicationHelper

  def full_title(page_title = "")
    base_title = "Task Management System"

    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def user_count
    User.count
  end

  def category_count
    Category.count
  end

  def tasks_count
    if current_user.admin
      Task.count
    else
      current_user.tasks.count
    end
  end

  def approved_task_count
    Task.where(approved: true).count
  end

  def set_task_count
    Task.where(assign_task_by: current_user.id).count
  end

  def notified_count
    Task.where(notify_hr: true).count
  end
end
