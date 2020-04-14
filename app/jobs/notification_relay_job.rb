class NotificationRelayJob < ApplicationJob
    queue_as :default

  def perform(notification)
    html = ApplicationController.render partial: "tasks/task", locals: {notification: notification}, formats: [:html]
    ActionCable.server.broadcast "notification:#{notification.recipient_id}", html: html
  end
end
