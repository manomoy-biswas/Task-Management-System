class AddForeignKeyToAssignTaskByInTasks < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :tasks, :users, column: :assign_task_by
  end
end
