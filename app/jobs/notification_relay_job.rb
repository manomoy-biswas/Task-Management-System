class NotificationRelayJob < ApplicationJob
    queue_as :default

  def perform(notification)
    unless notification.read_at != nil
      if notification.notifiable_type== "Task"
        if notification.action == "assigned"
          content = notification.user.name + " " + notification.action + " a task to you."
        elsif notification.action == "approved by"
          content = notification.user.name + " approved a task, assigned to " + User.find(Task.find(notification.notifiable_id).assign_task_to).name
        else
          content = notification.user.name + " " + notification.action + " a task, assigned to you."
        end
      end
      task_id = notification.notifiable_id
      count = Notification.where(recipient: notification.recipient_id).unread.count
      ActionCable.server.broadcast "notifications_channel_#{notification.recipient_id}", content: content, count: count, task_id: task_id
    end
  end
end
