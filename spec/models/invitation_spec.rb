require 'rails_helper'

RSpec.describe Invitation, type: :model do
  let(:invite) { Invitation.create(name: "Manomoy Biswas", email: "mano@gmail.com", invitation_token: "hhggfrssd") }
  subject { Invitation.new(name: "Manomoy Biswas", email: "mano@exampe.com", invitation_token: "hhggfrssd") }
  
  
  describe "Model validation test" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(50) }
    it { is_expected.to validate_length_of(:email).is_at_least(7).is_at_most(50) }
  end

  # Callback test

  describe "#valid_name" do
    context "with valid name" do
      it "is expected to be valid name" do
        subject.name = " manomoy Biswas  "
        expect(subject.send(:valid_name)).to eq("Manomoy Biswas")
      end
    end
  end

  describe "#valid_email" do
    context "with valid email" do
      it "is expected to be valid email" do
        subject.email = " manomoy@Gmail.coM  "
        expect(subject.send(:valid_email)).to eq("manomoy@gmail.com")
      end
    end
  end
end
