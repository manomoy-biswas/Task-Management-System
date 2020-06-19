require "rails_helper"

RSpec.describe Category, type: :model do
  subject { Category.new(name: "Birthday") }

  context "Validation tests:" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(30) }
  end
  context "Association tests:" do
    it { is_expected.to have_many(:tasks) }
  end

  context "Callback test " do
    it { is_expected.to callback(:valid_name).before(:validation) }
  end

  context "instance mrthod test:" do
    describe "#valid_name" do
      it "Category name should remove extra space and convet to title case when validated" do
        subject.name = " Campus hiring  "
        expect(subject.send(:valid_name)).to eq("Campus Hiring")
      end
    end
  end
end
