class CreateSubTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_tasks do |t|
      t.references :task, foreign_key: true
      t.string :name
      t.text :subtask_description
      t.boolean :submit, default: false

      t.timestamps
    end
  end
end
