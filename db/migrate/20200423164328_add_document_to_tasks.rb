class AddDocumentToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :document, :string
  end
end
