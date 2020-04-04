class Task < ApplicationRecord
  validates :task_name, presence: true, length: { maximum: 255 }
  validates :priority, :repeat, :assign_task_to, :task_category, :submit_date, presence: true
  validates :recurring_task presence:true, 
end
