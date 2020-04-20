class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:mark_as_read]
  
  def mark_as_read
    task=Task.find(@notification.notifiable_id) 
    @notification.update(read_at: Time.zone.now)
    if task.present?
      redirect_to task_path(task)
    else
      redirect to requst.referrer
    end
  end
  
  def mark_all_read
    @notifications = Notification.where(recipient: current_user).unread
    @notifications.update_all(read_at: Time.zone.now)
    redirect_to request.referrer
  end

  private
  def set_notification 
    @notification = Notification.find(params[:id])
  end
end
