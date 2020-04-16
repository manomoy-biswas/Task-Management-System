module NotificationsHelper
  def create_notification(notifiable_id, action)
    task=Task.find(notifiable_id)
    unless action == "approved by"
      Notification.create(recipient_id: task.user.id, user_id: task.assign_task_by, action: action, notifiable: task)
    else
      Notification.create(recipient_id: 1, user_id: task.assign_task_by, action: action, notifiable: task)
    end
  end
end
