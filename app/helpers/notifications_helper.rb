module NotificationsHelper
  def create_notification(notifiable_id, action)
    task=Task.find(notifiable_id)
    if action == "approved by"
      Notification.create(recipient_id: 1, user_id: task.assign_task_by, action: action, notifiable: task)
    elsif action == "notified"
      User.where(hr: 1).each do |user|
        Notification.create(recipient_id: user.id, user_id: 1, action: action, notifiable: task)
      end
    else
      Notification.create(recipient_id: task.user.id, user_id: task.assign_task_by, action: action, notifiable: task)
    end
  end
end
