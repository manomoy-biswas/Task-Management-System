class AddNotifyHrToTasks < ActiveRecord::Migration[6.0]
  def up
    add_column :tasks, :notify_hr, :boolean, default: false
  end
end
