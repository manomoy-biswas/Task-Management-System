class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.bigint :user_id, null: false
      t.bigint :recipient_id, null: false
      t.datetime :read_at
      t.string :action, null: false
      t.string :notifiable_type
      t.bigint :notifiable_id
  
      t.timestamps
    end
  end
end
