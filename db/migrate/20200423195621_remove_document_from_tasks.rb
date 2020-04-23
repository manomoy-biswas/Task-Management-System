class RemoveDocumentFromTasks < ActiveRecord::Migration[6.0]
  def change

    remove_column :tasks, :document, :string
  end
end
