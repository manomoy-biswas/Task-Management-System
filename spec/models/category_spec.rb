require "rails_helper"

RSpec.describe Category, type: :model do
  subject { Category.new(name: "Birthday") }

  context "Validation tests:" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name)}
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(30) }
  end
  context "Association tests:" do
    it { is_expected.to have_many(:tasks) }
  end
end