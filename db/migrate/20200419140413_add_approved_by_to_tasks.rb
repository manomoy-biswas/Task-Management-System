class AddApprovedByToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :approved_by, :string
  end
end
