class Notification < ApplicationRecord
  include SessionsHelper
  
  after_commit { NotificationRelayWorker.perform_async(self.id) }
  
  belongs_to :task, foreign_key: "notifiable_id", required: true
  belongs_to :user, foreign_key: "user_id", required: true
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"

  scope :unread, ->(user_id=nil) {where(recipient_id: user_id, read_at: nil).includes(:user, :recipient, :task)}
  
  scope :all_notification, ->(user_id=nil) {where(recipient_id: user_id).includes(:user, :recipient, :task)}
  
  scope :todays_notifications, -> (user_id = nil){where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).where(recipient_id: user_id)}
  
  scope :yesterdays_notifications, -> (user_id = nil){where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day).where(recipient_id: user_id)}
  
  scope :weekly_notifications, -> (date = nil, user_id = nil){where(created_at: date.at_beginning_of_week..date.at_end_of_week).where(recipient_id: user_id)}
  
  scope :monthly_notifications, -> (date = nil, user_id = nil){where(created_at: date.at_beginning_of_month..date.at_end_of_month).where(recipient_id: user_id)}
  
  scope :yearly_notifications, -> (date = nil, user_id = nil){where(created_at: date.at_beginning_of_year..date.at_end_of_year).where(recipient_id: user_id)}

  def self.create_notification(notifiable_id, action, notified_by=nil)
    task=Task.find(notifiable_id)
    case action
    when "approved"
      Notification.create(recipient_id: task.user.id, user_id: task.approved_by, action: action, notifiable_type: "Task", notifiable_id:task.id)
    when "approved by"
      User.where(admin: true).each do |user|
        Notification.create(recipient_id: user.id, user_id: task.assign_task_by, action: action, notifiable_type: "Task", notifiable_id:task.id)
      end
    when "notified"
      User.all_hr.each do |user|
        Notification.create(recipient_id: user.id, user_id: notified_by , action: action, notifiable_type: "Task", notifiable_id:task.id)
      end
    when "submitted"
      User.all_admin.each do |user|
        Notification.create(recipient_id: user.id, user_id: task.assign_task_to, action: action, notifiable_type: "Task", notifiable_id:task.id)
      end

      unless User.find(task.assign_task_by).admin
        Notification.create(recipient_id: task.assign_task_by, user_id: task.assign_task_to, action: action, notifiable_type: "Task", notifiable_id:task.id)
      end
    when "assigned", "updated"
      Notification.create(recipient_id: task.user.id, user_id: task.assign_by.id, action: action, notifiable_type: "Task", notifiable_id:task.id)
    else
      return
    end
  end

  def self.fetch_notification(filter = nil, user_id = nil)
    if filter.blank?
      Notification.all_notification(user_id).order("created_at DESC")
    elsif filter.downcase == "today"
      self.todays_notifications(user_id).order("created_at DESC")
    elsif filter.downcase == "yesterday"
      self.yesterdays_notifications(user_id).order("created_at DESC")
    elsif filter.downcase == "this week"
      self.weekly_notifications(Date.today, user_id).order("created_at DESC")
    elsif filter.downcase == "previous week"
      self.weekly_notifications(Date.today.at_beginning_of_week - 1, user_id).order("created_at DESC")
    elsif filter.downcase == "this month"
      self.monthly_notifications(Date.today, user_id).order("created_at DESC")
    elsif filter.downcase == "previous month"
      self.monthly_notifications(Date.today.at_beginning_of_month - 1, user_id).order("created_at DESC")
    elsif filter.downcase == "this year"
      self.yearly_notifications(Date.today, user_id).order("created_at DESC")
    elsif filter.downcase == "previous year"
      self.yearly_notifications(Date.today.at_beginning_of_year - 1, user_id).order("created_at DESC")
    end
  end
end
