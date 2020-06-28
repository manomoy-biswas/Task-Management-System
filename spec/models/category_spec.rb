require "rails_helper"

RSpec.describe Category, type: :model do
  subject { Category.new(name: "Birthday") }

  describe "Model validation test" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(30) }
  end
  describe "Model association test" do
    it { is_expected.to have_many(:tasks) }
  end

  context "Callback test " do
    it { is_expected.to callback(:valid_name).before(:validation) }
  end

  describe "#valid_name" do
    context "with valid category name" do
      it "is expected to be valid category name" do
        subject.name = " Campus hiring  "
        expect(subject.send(:valid_name)).to eq("Campus Hiring")
      end
    end
  end
end
