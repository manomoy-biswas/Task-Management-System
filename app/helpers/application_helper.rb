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
    if current_user.admin
      Task.approved_tasks.count
    else
      Task.users_approved_tasks(current_user.id).count
    end
  end

  def set_task_count
    Task.my_assigned_tasks(current_user.id).count
  end

  def notified_count
    Task.notified_tasks.count
  end
end
