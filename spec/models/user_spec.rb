require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:employee, dob: "01-01-2001") }
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:hr)}
  let (:user4) {create(:employee, name: "Manomoy Biswas")}

  context "Association tests" do
    it { is_expected.to have_many(:tasks) }
    it { is_expected.to have_many(:notifications) }
  end
  
  context "Callback tests:" do
    it "name should remove extra space and convet to title case when validated" do
      subject.name="manomoy biswas  "
      subject.valid?
      expect(subject.name).to eq("Manomoy Biswas")
    end
    it "email should remove extra space and convet to downcase when validated" do
      subject.email=" manomoyBiswas@gmail.com  "
      subject.valid?
      expect(subject.email).to eq("manomoybiswas@gmail.com")
    end
  end

  context "validation tests:" do
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
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

  context "Instance method testing:" do
    describe "#valid_dob?" do
      it "is expected to validate that :dob is valid" do
        user2.dob = "01-01-2009"
        expect(user2.valid_dob?).to eq(["#{user2.dob} is invalid. DOB should be before #{18.years.ago.to_date}"])
      end
      it "is expected to validate that :dob is not blank" do
        user2.dob = ""
        expect(user2.valid_dob?).to eq(["DOB can't be blank"])
      end
    end
  end

  context "class method test:" do
    describe "#all_except" do
      it "returns all userrs except given user" do
        expect(User.all_except(user2)).to_not include(user2)
      end
    end
    describe "#filter_by_role" do
      it "Display All user for paramiter = '' and user_role = 'Admin'" do
        expect(User.filter_by_role("", user1)).to include(user1, user2, user3, user4)
      end
      it "Display Admin user for paramiter = 'Admin' and user_role = 'Admin'" do
        expect(User.filter_by_role("Admin", user1)).to_not include(user2, user3, user4)
      end
      it "Display HR user for paramiter = 'HR' and user_role = 'Admin'" do
        expect(User.filter_by_role("HR", user1)).to_not include(user1, user2, user4)
      end
      it "Display Employee user for paramiter = 'Employee' and user_role = 'Admin'" do
        expect(User.filter_by_role("Employee", user1)).to_not include(user1, user3)
      end

      it "Not display Admin user for paramiter = '' and user_role = 'HR'" do
        expect(User.filter_by_role("", user3)).to_not include(user1)
      end
      it "Display HR user for paramiter = 'HR' and user_role = 'HR'" do
        expect(User.filter_by_role("HR", user3)).to include(user3)
      end
      it "Display Employee user for paramiter = 'Employee' and user_role = 'HR'" do
        expect(User.filter_by_role("Employee", user3)).to_not include(user1, user3)
      end
    end
  end
end
