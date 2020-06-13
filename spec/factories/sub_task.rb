FactoryBot.define do
  factory :assigned_subtask, class:SubTask do
    name {Faker::Lorem.sentence(word_count = 5)}
    subtask_description {Faker::Lorem.paragraph(rand(10..15))}
  end
end