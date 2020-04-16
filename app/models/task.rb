class Task < ApplicationRecord
  belongs_to :user, foreign_key: "assign_task_to", required: true
  belongs_to :category, foreign_key: "task_category", required: true
  has_many :sub_task, dependent: :destroy
  accepts_nested_attributes_for :sub_task, reject_if: lambda { |a| a[:name].blank? }, allow_destroy: true
  after_destroy :destroy_notifications 
  
  validates :task_name, presence: true, length: { maximum: 255 }
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validate :valid_submit_date, on: :create
  has_attached_file :document
  validates_attachment :document, content_type: {content_type: %w(image/jpeg image/jpg image/png application/pdf)}

  def valid_submit_date
    if submit_date.to_datetime <= DateTime.now + 1.day
      errors.add(:submit_date, " can not be assign to a previous date")
    end
  end
  def self.all_task_assigned_to(user)
    Task.where(assign_task_to: user)
  end
  private
  # def create_task_notification
  #   Notification.create(recipient: @task.user, user: current_user, action: "assigned", notifiable: @task)
  # end
  # def update_task_notification
  #   Notification.create(recipient: @task.user, user: current_user, action: "updated", notifiable: @task)
  # end
  def destroy_notifications 
    unread_notifications = Notification.where(notifiable: self).all
    unread_notifications.each do |notification| 
      notification.destroy
    end
  end
end
