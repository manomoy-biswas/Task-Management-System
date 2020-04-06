class Task < ApplicationRecord
  validates :task_name, presence: true, length: { maximum: 255 }
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validate :valid_submit_date
  has_attached_file :document
  validates_attachment :document, content_type: {content_type: %w(image/jpeg image/jpg image/png application/pdf)}

  def valid_submit_date
    if submit_date.to_datetime <= DateTime.now
      error.add(:submit_date, " can not be assign to a previous date")
    end
  end
end
