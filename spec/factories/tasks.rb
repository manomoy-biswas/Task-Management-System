FactoryBot.define do
  factory :assigned_task1, class: Task do
    task_category {1}
    task_name {Faker::Lorem.sentence}
    assign_task_to {1}
    assign_task_by {1}
    priority {["Low", "Medium", "High"].sample}
    repeat {"One_Time"}
    submit_date {Faker::Date.between(2.days.from_now, 2.years.from_now)}
    recurring_task {false}
    description {Faker::Lorem.paragraph(rand(30..40))}
  end

  factory :assigned_task2, class: Task do
    task_category {1}
    task_name {Faker::Lorem.sentence}
    assign_task_to {1}
    assign_task_by {1}
    priority {["Low", "Medium", "High"].sample}
    repeat {"Monthly"}
    submit_date {Faker::Date.between(2.days.from_now, 2.years.from_now)}
    recurring_task {true}
    description {Faker::Lorem.paragraph(rand(30..40))}
  end
  
  factory :submitted_task, class: Task do
    task_category {1}
    task_name {Faker::Lorem.sentence}
    assign_task_to {1}
    assign_task_by {1}
    priority {["Low", "Medium", "High"].sample}
    repeat {"Monthly"}
    submit_date {Faker::Date.between(2.days.from_now, 2.years.from_now)}
    recurring_task {true}
    description {Faker::Lorem.paragraph(rand(30..40))}
    submit {true}
  end

  factory :approved_task, class: Task do
    task_category {1}
    task_name {Faker::Lorem.sentence}
    assign_task_to {1}
    assign_task_by {1}
    priority {["Low", "Medium", "High"].sample}
    repeat {"Monthly"}
    submit_date {Faker::Date.between(2.days.from_now, 2.years.from_now)}
    recurring_task {true}
    description {Faker::Lorem.paragraph(rand(30..40))}
    submit {true}
    approved {true}
  end
end