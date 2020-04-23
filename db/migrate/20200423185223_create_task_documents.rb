class CreateTaskDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :task_documents do |t|
      t.references :task, null: false, foreign_key: true
      t.string :document

      t.timestamps
    end
  end
end
