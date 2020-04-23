class ChangeForeinkeyInNotification < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :notifications, :tasks, column: :notifiable_id
    change_column :notifications, :user_id, :bigint
  end
end
