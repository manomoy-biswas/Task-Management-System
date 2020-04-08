class Task < ApplicationRecord
  belongs_to :user, foreign_key: "assign_task_to", required: true
  belongs_to :category, foreign_key: "task_category", required: true
  has_many :sub_task, dependent: :destroy
  accepts_nested_attributes_for :sub_task, reject_if: lambda { |a| a[:name].blank? }, allow_destroy: true
  
  validates :task_name, presence: true, length: { maximum: 255 }
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validate :valid_submit_date
  has_attached_file :document
  validates_attachment :document, content_type: {content_type: %w(image/jpeg image/jpg image/png application/pdf)}

  def valid_submit_date
    if submit_date.to_datetime <= DateTime.now + 1.day
      error.add(:submit_date, " can not be assign to a previous date")
    end
  end
  def self.all_task_assigned_to(user)
    Task.where(assign_task_to: user)
  end
end
