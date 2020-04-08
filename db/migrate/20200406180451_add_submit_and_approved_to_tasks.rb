class AddSubmitAndApprovedToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :submit, :boolean, default: false
    add_column :tasks, :approved, :boolean, default: false
  end
end
