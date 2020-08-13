class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string     :email,                 null: false, limit: 50
      t.boolean    :admin, default: false
      t.boolean    :hr,    default: false
      t.string     :name,                  null: false, limit: 30
      t.string     :phone
      t.date       :dob,                   null: false
      t.string     :password_digest,       null: true
      t.string     :auth_token
      t.string     :password_reset_token
      t.datetime   :password_reset_sent_at
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
  end
end
