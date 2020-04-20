class ChangeDatatypeOfApprovedByInTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks,:approved_by,:bigint
  end
end
