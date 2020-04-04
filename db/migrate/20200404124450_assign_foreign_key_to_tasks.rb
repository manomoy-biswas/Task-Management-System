class AssignForeignKeyToTasks < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :tasks, :users, column: :assign_task_to
    add_foreign_key :tasks, :categories, column: :task_category
  end
end
