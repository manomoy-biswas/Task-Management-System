class CreateSubTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_tasks do |t|
      t.string :name
      t.boolean :submit, default: false
      t.datetime :submitdate
      t.references :task, foreign_key: true

      t.timestamps
    end
  end
end
