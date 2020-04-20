class NotificationRelayJob < ApplicationJob
    queue_as :default

  def perform(notification)
    return if notification.read_at != nil

    if notification.notifiable_type== "Task"
      if notification.action == "assigned"
        text = notification.user.name + " " + notification.action + " a task to you."
        content = notification_content("fa-tasks",text, notification)

      elsif notification.action == "approved by"
        text = notification.user.name + " approved a task, assigned to " + User.find(Task.find(notification.notifiable_id).assign_task_to).name
        content = notification_content("fa-check-square",text, notification)

      elsif notification.action == "approved"
        text = notification.user.name + " " + notification.action + " a task, assigned to You."
        content = notification_content("fa-check-circle",text, notification)

      elsif notification.action == "notified"
        text = notification.user.name + " notification: a task has been approved. You can view task"
        content = notification_content("fa-bell",text, notification)

      else
        text = notification.user.name + " " + notification.action + " a task, assigned to you."
        content = notification_content("fa-tasks",text, notification)
      end
    end

    count = Notification.where(recipient: notification.recipient_id).unread.count
    ActionCable.server.broadcast "notifications_channel_#{notification.recipient_id}", content: content, count: count
  end
  private

  def notification_content(classname, text, notification)
    "<a class=\"dropdown-item\" href=\"http://localhost:3000/tasks/" +
     notification.notifiable_id.to_s + "\" value=\"" + notification.notifiable_id.to_s + "\">" +
       "<div class=\"row\">" +
         "<div class=\"col-1\">" +
           "<i class=\"fa "+ classname + "\"></i>" +
         "</div>" +
         "<div class=\"col-11\">" +
           "<p>" + text + "</p>"  +
         "</div>" +
       "</div>" +
     "</a>"
  end
end