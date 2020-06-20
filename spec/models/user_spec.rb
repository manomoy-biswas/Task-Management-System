require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:employee, dob: "01-01-2001") }
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:hr)}
  let (:user4) {create(:employee, name: "Manomoy Biswas")}

  context "Association tests" do
    describe "has_many :tasks" do
      it { is_expected.to have_many(:tasks) }
    end
    describe "has_many :notifications" do
      it { is_expected.to have_many(:notifications) }
    end
  end
  
  context "Callback tests:" do 
    describe "before_validation :valid_name" do
      it { is_expected.to callback(:valid_name).before(:validation) }
    end
    describe "before_validation :valid_email" do
      it { is_expected.to callback(:valid_email).before(:validation) }
    end
  end

  context "validation tests:" do
    describe "have_secure_password" do
      it { is_expected.to have_secure_password }
    end
    describe "validate_presence_of(:name)" do
      it { is_expected.to validate_presence_of(:name) }
    end
    describe "validate_presence_of(:email)" do
      it { is_expected.to validate_presence_of(:email) }
    end
    describe "validate_presence_of(:phone)" do
      it { is_expected.to validate_presence_of(:phone) }
    end
    describe "validate_uniqueness_of(:email)" do
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end
    describe "validate_uniqueness_of(:phone)" do
      it { is_expected.to validate_uniqueness_of(:phone).ignoring_case_sensitivity }
    end
    describe "validate_length_of(:name)" do
      it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(50) }
    end
    describe "validate_length_of(:phone)" do
      it { is_expected.to validate_length_of(:phone).is_equal_to(10) }
    end
    describe "validate_length_of(:password)" do
      it { is_expected.to validate_length_of(:password).is_at_least(5) }
    end
    describe "allow_value(:email)" do
      it { is_expected.to allow_value("manomoybiswas1414@gmail.com", "manomoybiswas1414@gmail.co.in").for(:email)}
    end
    describe "not allow_value(:email)" do
      it { is_expected.to_not allow_value("manomoybiswas1414gmail.co.in").for(:email)}
    end
    describe "allow_value(:phone)" do
      it { is_expected.to allow_value(8348682398).for(:phone) }
    end
    describe "not allow_value(:phone)" do
      it { is_expected.to_not allow_value(2348682398).for(:phone) }
    end
    describe "allow_value(:password)" do
      it { is_expected.to allow_value(nil).for(:password) }
    end
    describe "save_succesfully" do
      it "ensure save succesfully" do
        expect(subject).to be_valid
      end
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
        expect(user2.send(:valid_dob?)).to eq(["#{user2.dob} is invalid. DOB should be before #{18.years.ago.to_date}"])
      end
      it "is expected to validate that :dob is not blank" do
        user2.dob = ""
        expect(user2.send(:valid_dob?)).to eq(["DOB can't be blank"])
      end
    end
    describe "#valid_name" do
      it "name should remove extra space and convet to title case when validated" do
        subject.name="manomoy biswas  "
        expect(subject.send(:valid_name)).to eq("Manomoy Biswas")
      end
    end
    describe "#valid_email" do
      it "email should remove extra space and convet to downcase when validated" do
        subject.email=" manomoyBiswas@gmail.com  "
        expect(subject.send(:valid_email)).to eq("manomoybiswas@gmail.com")
      end
    end
  end

  context "class method test:" do
    describe "#all_except" do
      it "returns all userrs except given user" do
        expect(User.all_except(user2)).to_not include(user2)
      end
    end

    describe "#from_omniauth" do
      it "using omniauth" do
        user1 = create(:employee, email: "manomoy@gmail.com")
        OmniAuth.config.test_mode = true
        expect(User.from_omniauth(OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: "google_oauth2",
            uid: "12345678910",
            info: {
              email: "manomoy@gmail.com",
              first_name: "Manomoy",
              last_name: "Biswas"
            },
            credentials: {
              token: "abcdefg12345",
              refresh_token: "abcdefg12345",
              expires_at: DateTime.now,
            }
          }))).to eq(user1)
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
