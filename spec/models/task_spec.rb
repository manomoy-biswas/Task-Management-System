require "rails_helper"

RSpec.describe SubTask, type: :model do
  subject { SubTask.new(task_category: rand(1..Category.all.count),
    task_name: Faker::Lorem.sentence,
    assign_task_to: [2, 4].sample,
    assign_task_by: [1, 3].sample,
    priority: ["Low", "Medium", "High"].sample,
    repeat: "One_Time",
    submit_date: Faker::Date.between(1.days.from_now, 2.years.from_now),
    recurring_task: false,
    description: Faker::Lorem.paragraph(rand(30..40))) }
    before { subject.save }

  it "should has_many sub tasks" do
    expect(Task.reflect_on_association(:sub_task).macro).to eq :has_many
  end

  it "name should be present" do
    subject.task_name = nil
    expect(subject).to_not be_valid
  end

  it 'name lenght should not be too short' do
    subject.name = 'aaaa'
    expect(subject).to_not be_valid
  end

  it 'name lenght should not be too large' do
    subject.name = 'a' * 255
    expect(subject).to be_valid
  end

  it "should belong_to task" do
    expect(SubTask.reflect_on_association(:task).macro).to eq :belongs_to
  end
end