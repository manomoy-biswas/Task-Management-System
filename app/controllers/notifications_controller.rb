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
      flash[:success] = "Notification deleted"
      redirect_to request.referrer
    else
      flash[:danger] = "Notification doesn't exist."
    end
  end
  
  def mark_all_read
    @notifications = Notification.unread(current_user.id)
    @notifications.update_all(read_at: Time.zone.now)
    redirect_to request.referrer
  end
  
  def mark_as_read
    task=Task.find(@notification.notifiable_id) 
    @notification.update(read_at: Time.zone.now)
    if task.present?
      redirect_to task_path(task)
    else
      redirect to requst.referrer
    end
  end

  private
  
  def set_notification 
    @notification = Notification.find(params[:id])
  end
end