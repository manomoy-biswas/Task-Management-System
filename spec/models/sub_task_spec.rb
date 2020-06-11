require "rails_helper"

RSpec.describe SubTask, type: :model do
  subject { SubTask.new(name: "Lorem ipsum dolor sit", subtask_description: "a" * 300) }
  # before { subject.save }

  it "name should be present" do
    subject.name = nil
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