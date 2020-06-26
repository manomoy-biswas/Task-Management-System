class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.bigint :task_category, null: false
      t.bigint :assign_task_to, null: false
      t.bigint :assign_task_by, null: false
      t.string :priority, null: false
      t.string :task_name, null: false
      t.text :description
      t.string :repeat, null: false
      t.datetime :submit_date, null: false
      t.boolean :recurring_task, default: false
      t.boolean :submit, default: false
      t.boolean :approved, default: false
      t.bigint :approved_by
      t.boolean :notify_hr, default: false
      

      t.timestamps
    end
  end
end
