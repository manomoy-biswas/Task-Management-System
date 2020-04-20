# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user, foreign_key: 'assign_task_to', required: true
  belongs_to :category, foreign_key: 'task_category', required: true
  has_many :sub_task, dependent: :destroy
  accepts_nested_attributes_for :sub_task, reject_if: ->(a) { a[:name].blank? },
                                           allow_destroy: true
  after_destroy :destroy_notifications
  after_create :task_reminder_email


  after_create { TaskMailerJob.perform_now(self,"create") }
  after_update { TaskMailerJob.perform_now(self,"update") }

  validates :task_name, presence: true, length: { maximum: 255 }
  validates :priority, :repeat, :assign_task_to, :task_category,
            :submit_date, presence: true
  validate :valid_submit_date, on: :create
  has_attached_file :document
  validates_attachment :document,
                       content_type: { content_type: %w[image/jpeg
                                                        image/jpg
                                                        image/png
                                                        application/pdf] }

  def valid_submit_date
    return unless submit_date.to_datetime <= DateTime.now + 1.day

    errors.add(:submit_date, ' can not be assign to a previous date')
  end

  def find_user_name(user_id)
    User.find(id: user_id).name
  end

  private

  def task_reminder_email
    return if DateTime.now.utc + 7.days > self.submit_date.to_datetime

    TaskMailer.delay(run_at: self.submit_date.to_datetime - 7.days).task_reminder_email(self)
  end

  def destroy_notifications
    notifications = Notification.where(notifiable: self).all
    notifications.each(&:destroy)
  end
end
