class AddForeignKeyUserIdInNotifications < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :notifications, :users, column: :user_id
  end
end
