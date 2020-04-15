class NotificationRelayJob < ApplicationJob
    queue_as :default

  def perform(notification)
    if notification.notifiable_type== "Task"
      if notification.action == "assigned"
        content = notification.user.name + " " + notification.action + " a task to you."
      else
        content = notification.user.name + " " + notification.action + " a task, assigned to you."
      end
    end
    count = Notification.where(recipient: notification.recipient_id).unread.count
    ActionCable.server.broadcast "notifications_channel_#{notification.recipient_id}", content: content, count: count
  end
end
