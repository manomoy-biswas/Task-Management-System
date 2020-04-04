class ChangeDataTypeToBigintInTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks, :assign_task_to, :bigint
    change_column :tasks, :task_category, :bigint
  end
end
