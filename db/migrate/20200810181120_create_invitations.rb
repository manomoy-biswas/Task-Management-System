class CreateInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :invitations do |t|
      t.string :name,             null: false, limit: 50
      t.string :email,            null: false, limit: 50
      t.string :invitation_token, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
