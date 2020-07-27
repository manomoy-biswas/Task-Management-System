User.new(id: 1, name: "Admin", email: "admin@gmail.com", phone:"7123456789", dob: "01-01-2000", password: "admin", password_confirmation: "admin", admin: true, hr: false).save(validate: false)
User.new(id: 2, name: "Arnab Roy", email: "manomoybiswas95@gmail.com", phone: "7894561230", dob: "01-01-1996").save(validate: false)
User.new(id: 3, name: "Manomoy Biswas", email: "manomoy26@gmail.com", phone: "7894561231", dob: "10-09-1995").save(validate: false)
User.new(id: 4, name: Faker::Name.name, email: "manomoybiswas1414@gmail.com", phone: "7894561232", dob: "10-09-1995").save(validate: false)
User.new(id: 5, name: Faker::Name.name, email: "biswasmanomoy@gmail.com", phone: "7894561233", dob: "10-09-2000",admin: false, hr: true).save(validate: false)

%w(Birthday Interview Training Exams Campus Event Hiring).each do |category|
  Category.new(name: category).save
end

50.times do
  repeat_interval =  ["One_Time", "Daily", "Weekly", "Monthly", "Quarterly", "Half_yearly", "Yearly"].sample

  if repeat_interval != "One_Time"
    recurring = true
  else
    recurring = false
  end

  Task.create(
    task_category: rand(1..Category.all.count),
    task_name: Faker::Lorem.sentence,
    assign_task_to: [2, 4].sample,
    assign_task_by: [1, 3].sample,
    priority: ["Low", "Medium", "High"].sample,
    repeat: repeat_interval,
    submit_date: Faker::Date.between(1.days.from_now, 2.years.from_now),
    recurring_task: recurring,
    description: Faker::Lorem.paragraph(rand(30..40))
  )
  rand(1..3).times do
    SubTask.create(
      task_id: Task.all.count,
      name: Faker::Lorem.sentence,
      subtask_description: Faker::Lorem.paragraph(rand(10..15))
    )
  end
end

Task.__elasticsearch__.create_index! force: true
Task.import