class NotificationRelayWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(notification_id)
    @notification = Notification.find(notification_id)
    return if @notification.read_at != nil

    if @notification.notifiable_type== "Task"
      case @notification.action
      when "assigned"
        text = @notification.action + " a task to you."
        content = notification_content("fa-tasks",text, @notification)

      when "approved by"
        text = " approved a task, assigned to " + User.find(Task.find(@notification.notifiable_id).assign_task_to).name
        content = notification_content("fa-check-square",text, @notification)

      when "approved"
        text = @notification.action + " a task, assigned to You."
        content = notification_content("fa-check-circle",text, @notification)

      when "submitted"
        if @notification.recipient_id == Task.find(@notification.notifiable_id).assign_task_by
          text = @notification.action + " a task, assigned by You."
        else
         text = "#{@notification.action} a task, assigned by #{User.find(Task.find(@notification.notifiable_id).assign_task_by).name}"
        end
        content = notification_content("fa-check-circle",text, @notification)

      when "notified"
        text = "A task has been approved. You can view task"
        content = notification_content("fa-bell",text, @notification)
      when "Daily", "Weakly", "Monthly", "Quarterly", "Half_Yearly", "Yearly"
        text = "Please submit your task on or before " +  DateTime.parse(Task.find(@notification.notifiable_id).submit_date.to_s).strftime("%d-%m-%Y %I:%M %p") + "."
        content = recurring_notification_content("fa-bullhorn",text, @notification)
      else
        text =  @notification.action + " a task, assigned to you."
        content = notification_content("fa-tasks",text, @notification)
      end
    end

    count = Notification.unread(@notification.recipient_id).count
    ActionCable.server.broadcast "notifications_channel_#{@notification.recipient_id}", content: content, count: count
  end
  
  private

  def notification_content(classname, text, notification)
    "<a class=\"dropdown-item\" href=\"http://localhost:3000/notifications/" +
     notification.id.to_s + "/mark_as_read\" value=\"" + notification.id.to_s + "\">" +
      "<div class=\"notify-content\">" +
        "<div class=\"notify-image\">" +
          "<i class=\"fa "+ classname + "\"></i>" +
        "</div>" +
        "<div class=\"notify-info\">" +
          "<h5>" + User.find(notification.user_id).name + " </h5>" +
          "<p>" + text + "</p>" +
          "<span class=\"notify-time\"> Just now <span>" +
          "</div>" +
          "</div>" +
        "</a>"
  end
  
  def recurring_notification_content(classname, text, notification)
    "<a class=\"dropdown-item\" href=\"http://localhost:3000/notifications/" +
     notification.id.to_s + "/mark_as_read\" value=\"" + notification.id.to_s + "\">" +
      "<div class=\"notify-content\">" +
        "<div class=\"notify-image\">" +
          "<i class=\"fa "+ classname + "\"></i>" +
        "</div>" +
        " <div class=\"notify-info\">" +
          "<h5>" + @notification.action + " reminder: </h5>" +
         "<p>" + text + "</p>" +
          "<span class=\"notify-time\"> Just now <span>"
        "</div>" +
      "</div>" +
    "</a>"
  end
end
