class AddDescriptionToSubTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_tasks, :subtask_description, :string
  end
end
