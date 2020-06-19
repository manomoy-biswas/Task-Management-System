class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:destroy, :mark_as_read]

  def index
    @notifications = Notification.all_notification(current_user.id).includes(:user, :recipient, :task).order("created_at DESC")
  end

  def destroy
    return unless @notification.recipient_id == current_user.id
    
    if @notification.present?
      @notification.destroy
      redirect_to request.referrer, flash: { success: "Notification deleted" }
    else
      flash[:danger] = "Notification doesn't exist."
    end
  end
  
  def mark_all_read
    @notifications = Notification.unread(current_user.id)
    redirect_to request.referrer if @notifications.update_all(read_at: Time.zone.now)
  end
  
  def mark_as_read
    task=Task.find(@notification.notifiable_id) 
    redirect_to task_path(task) if @notification.update(read_at: Time.zone.now) && task.present?
  end

  private
  
  def set_notification 
    @notification = Notification.find(params[:id])
  end
end
