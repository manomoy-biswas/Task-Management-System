require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:employee, dob: "01-01-2001") }
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:hr)}
  let (:user4) {create(:employee, name: "Manomoy Biswas")}

  #Assiciation test
  describe "has_many :tasks" do
    it { is_expected.to have_many(:tasks) }
  end
  describe "has_many :notifications" do
    it { is_expected.to have_many(:notifications) }
  end
  
  #callback test
  describe "before_validation :valid_name" do
    it { is_expected.to callback(:valid_name).before(:validation) }
  end
  describe "before_validation :valid_email" do
    it { is_expected.to callback(:valid_email).before(:validation) }
  end

  #Validation test
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


  #scope test
  describe ".all_users_except_admin" do
    context "For non admin user" do
      it "includes only hr and employee" do
        expect(User.all_users_except_admin).to include(user2, user3, user4)
      end
    end
    
    context "for admin user" do
      it "explude admin" do
        expect(User.all_users_except_admin).to_not include(user1)
      end
    end
  end

  describe ".all_hr" do
    context "for hr's" do
      it "includes only hr users" do
        expect(User.all_hr).to include(user3)
      end
    end
    
    context "for admin & employees" do
      it "excludes admin & employees" do
        expect(User.all_hr).to_not include(user1, user2, user4)
      end
    end
  end
  
  describe ".all_admin" do
    context "for admin" do
      it "includes only admin users" do
        expect(User.all_admin).to include(user1)
      end
    end
    
    context "for hr & employee" do
      it "excludes hr & employee" do
        expect(User.all_admin).to_not include(user2, user3, user4)
      end
    end
  end
  
  describe ".all_employee" do
    context "for employees" do
      it "includes only employees" do
        expect(User.all_employee).to include(user2, user4)
      end
    end
    
    context "for admin & hr" do
      it "exclude admin & hr's" do
        expect(User.all_employee).to_not include(user1, user3)
      end
    end
  end

  #Instance ethod test
  describe "#valid_dob?" do
    context "for valid DOB" do
      it "is expected to validate that :dob is valid" do
        user2.dob = "01-01-2009"
        expect(user2.send(:valid_dob?)).to eq(["#{user2.dob} is invalid. DOB should be before #{18.years.ago.to_date}"])
      end
    end
    
    context "for invalid DOB" do
      it "is expected to validate that :dob is not blank" do
        user2.dob = ""
        expect(user2.send(:valid_dob?)).to eq(["DOB can't be blank"])
      end
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

  describe "#all_except" do
    context "for selected user" do
      it "returns all userrs except given user" do
        expect(User.all_except(user2)).to include(user1, user3, user4)
      end
    end

    context "for not selected user" do
      it "returns all userrs except given user" do
        expect(User.all_except(user2)).to_not include(user2)
      end
    end
  end

  describe "#from_omniauth" do
    context "for refistered user" do
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

    context "for non registerd user" do
      it "using omniauth" do
        user1 = create(:employee, email: "manomoy@gmail.com")
        OmniAuth.config.test_mode = true
        expect(User.from_omniauth(OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: "google_oauth2",
            uid: "12345678910",
            info: {
              email: "manomoybiswas1414@gmail.com",
              first_name: "Manomoy",
              last_name: "Biswas"
            },
            credentials: {
              token: "abcdefg12345",
              refresh_token: "abcdefg12345",
              expires_at: DateTime.now,
            }
          }))).to eq(nil)
      end
    end
  end
    
  describe "#filter_by_role" do
    context "for no paramiter & user type Admin" do
      it "is expected to display all users" do
        expect(User.filter_by_role("", user1)).to include(user1, user2, user3, user4)
      end
    end
    
    context "for Admin paramiter & user type Admin" do
      it "is expected to display Admin users" do
        expect(User.filter_by_role("Admin", user1)).to include(user1)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("Admin", user1)).to_not include(user2, user3, user4)
      end
    end
    
    context "for HR paramiter & user type Admin" do
      it "is expected to display HR users" do
        expect(User.filter_by_role("HR", user1)).to include(user3)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("HR", user1)).to_not include(user1, user2, user4)
      end
    end
    
    context "for Employee paramiter & user type Admin" do
      it "is expected to display Employee users" do
        expect(User.filter_by_role("Employee", user1)).to include(user2, user4)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("Employee", user1)).to_not include(user1, user3)
      end
    end

    context "for no paramiter & user type HR" do
      it "is expected to display all users expect admin" do
        expect(User.filter_by_role("", user3)).to include(user2, user3, user4)
      end

      it "is expect not to display Admin users" do
        expect(User.filter_by_role("", user3)).to_not include(user1)
      end
    end

    context "for HR paramiter & user type HR" do
      it "is expected to display HR users" do
        expect(User.filter_by_role("HR", user3)).to include(user3)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("HR", user3)).to_not include(user1, user2, user4)
      end
    end

    context "for Employee paramiter & user type HR" do
      it "is expected to display Employee users" do
        expect(User.filter_by_role("Employee", user3)).to include(user2, user4)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("Employee", user3)).to_not include(user1, user3)
      end
    end
  end
end
