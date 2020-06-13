require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:employee) }
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:hr)}
  let (:user4) {create(:employee, name: "Manomoy Biswas")}
  context "validation tests:" do
    
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_presence_of(:dob) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:phone).ignoring_case_sensitivity }
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(50) }
    it { is_expected.to validate_length_of(:phone).is_equal_to(10) }
    it { is_expected.to validate_length_of(:password).is_at_least(5) }
    it { is_expected.to allow_value("manomoybiswas1414@gmail.com", "manomoybiswas1414@gmail.co.in").for(:email)}
    it { is_expected.to_not allow_value("manomoybiswas1414gmail.co.in").for(:email)}
    it { is_expected.to allow_value(8348682398).for(:phone) }
    it { is_expected.to_not allow_value(2348682398).for(:phone) }
    it { is_expected.to allow_value(nil).for(:password) }

    it "ensure save succesfully" do
      expect(subject).to be_valid
    end    
  end

  context "Association tests" do
    it { is_expected.to have_many(:tasks) }
    it { is_expected.to have_many(:notifications) }
  end

  context "scope tests:" do
    describe ".all_users_except_admin" do
      it "includes only hr and employee" do
        expect(User.all_users_except_admin).to include(user2, user3)
      end
    end
    describe ".all_hr" do
      it "includes only hr users" do
        expect(User.all_hr).to include(user3)
      end
    end
    describe ".all_admin" do
      it "includes only admin users" do
        expect(User.all_admin).to include(user1)
      end
    end
    describe ".all_employee" do
      it "includes only employees" do
        expect(User.all_employee).to include(user2)
      end
    end
  end

  context "Instance method tests:" do
    describe "#user_name" do
      it "returns users name" do
        expect(user4.user_name).to eq("Manomoy Biswas")
      end
    end
    # describe "#total_users" do
    #   it "returns total user" do
    #     expect(user4.total_users).to eq(1)
    #   end
    # end
  end
end
