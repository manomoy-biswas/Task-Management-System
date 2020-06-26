class AddForeinkeyInNotification < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :notifications, :tasks, column: :notifiable_id
  end
end
