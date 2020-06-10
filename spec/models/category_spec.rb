require "rails_helper"

RSpec.describe Category, type: :model do
  subject { Category.new(name: "Birthb") }
  # before { subject.save }

  it "name should be present" do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it 'name lenght should not be too short' do
    subject.name = 'a'
    expect(subject).to_not be_valid
  end

  it 'name lenght should not be too large' do
    subject.name = 'a' * 30
    expect(subject).to be_valid
  end

  before { Category.create!(name: "Birthday") }
  it "name should be unique" do
    expect(subject).to be_valid
  end

  it "should has_many tasks" do
    expect(Category.reflect_on_association(:tasks).macro).to eq :has_many
  end
end