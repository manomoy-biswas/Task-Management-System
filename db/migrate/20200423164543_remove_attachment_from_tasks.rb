class RemoveAttachmentFromTasks < ActiveRecord::Migration[6.0]
  def change
    remove_attachment :tasks, :document
  end
end
