# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_05_093212) do

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "recipient_id", null: false
    t.bigint "notifiable_id", null: false
    t.string "action", null: false
    t.string "notifiable_type", null: false
    t.datetime "read_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notifiable_id"], name: "fk_rails_4b545d474c"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "sub_tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id"
    t.string "name"
    t.text "subtask_description"
    t.boolean "submit", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["task_id"], name: "index_sub_tasks_on_task_id"
  end

  create_table "task_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.string "document"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["task_id"], name: "index_task_documents_on_task_id"
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "task_category", null: false
    t.bigint "assign_task_to", null: false
    t.bigint "assign_task_by", null: false
    t.string "priority", null: false
    t.string "task_name", null: false
    t.text "description"
    t.string "repeat", null: false
    t.datetime "submit_date", null: false
    t.boolean "recurring_task", default: false
    t.boolean "submit", default: false
    t.boolean "approved", default: false
    t.bigint "approved_by"
    t.boolean "notify_hr", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assign_task_by"], name: "fk_rails_d83cdb5373"
    t.index ["assign_task_to"], name: "fk_rails_8503550591"
    t.index ["task_category"], name: "fk_rails_38c638f0b2"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.boolean "admin", default: false
    t.boolean "hr", default: false
    t.string "name", null: false
    t.string "phone"
    t.date "dob", null: false
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "avater"
    t.string "auth_token"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  add_foreign_key "notifications", "tasks", column: "notifiable_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "sub_tasks", "tasks"
  add_foreign_key "task_documents", "tasks"
  add_foreign_key "tasks", "categories", column: "task_category"
  add_foreign_key "tasks", "users", column: "assign_task_by"
  add_foreign_key "tasks", "users", column: "assign_task_to"
end
