class ChangeDatatypeOfDescriptionToSubTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :sub_tasks, :subtask_description, :longtext
  end
end
