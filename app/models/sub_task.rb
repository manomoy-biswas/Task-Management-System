class SubTask < ApplicationRecord
  belongs_to :task

  before_validation { self.name = name.to_s.squeeze(" ").strip.capitalize }

  # VALID_SUB_TASK_NAME_REGEX = /\A[a-zA-Z][a-zA-Z\. ]*\z/.freeze

  validates :name, presence: true, length: { in: 3..255 }

  scope :find_subtasks, ->(task_id = null) { where(task_id: task_id) }
  scope :find_not_submitted_subtasks, ->(task_id = null) { where(task_id: task_id, submit: false)}

  def self.all_subtasks_submitted(task)
    @subtasks = SubTask.find_not_submitted_subtasks(task.id)
    return @subtasks.blank? 
  end
end