class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.bigint :recipient_id, null: false
      t.bigint :notifiable_id, null: false
      t.string :action, null: false
      t.string :notifiable_type, null: false
      t.datetime :read_at
  
      t.timestamps
    end
  end
end
