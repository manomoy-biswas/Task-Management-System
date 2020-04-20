class Notification < ApplicationRecord
  after_commit { NotificationRelayJob.perform_now(self) }
  belongs_to :user
  belongs_to :recipient, class_name: "User"
  belongs_to :notifiable, class_name: "Task", polymorphic: true
  scope :unread, ->{where(read_at: nil)}
end
