require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:employee, dob: "01-01-2001") }
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:hr)}
  let (:user4) {create(:employee, name: "Manomoy Biswas")}

  #Assiciation test
  describe "Model association" do
    it { is_expected.to have_many(:tasks) }
    it { is_expected.to have_many(:notifications) }
  end
  
  #callback test
  context "Callbacks" do
    it { is_expected.to callback(:valid_name).before(:validation) }
    it { is_expected.to callback(:valid_email).before(:validation) }
  end

  #Validation test
  describe "model validation" do
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

  #scope test
  describe ".all_users_except_admin" do
    context "when non admin user" do
      it "includes only hr and employee" do
        expect(User.all_users_except_admin).to include(user2, user3, user4)
      end
    end
    
    context "when admin user" do
      it "explude admin" do
        expect(User.all_users_except_admin).to_not include(user1)
      end
    end
  end

  describe ".all_hr" do
    context "when hr's" do
      it "includes only hr users" do
        expect(User.all_hr).to include(user3)
      end
    end
    
    context "when admin & employees" do
      it "excludes admin & employees" do
        expect(User.all_hr).to_not include(user1, user2, user4)
      end
    end
  end
  
  describe ".all_admin" do
    context "when admin" do
      it "includes only admin users" do
        expect(User.all_admin).to include(user1)
      end
    end
    
    context "when hr & employee" do
      it "excludes hr & employee" do
        expect(User.all_admin).to_not include(user2, user3, user4)
      end
    end
  end
  
  describe ".all_employee" do
    context "when employees" do
      it "includes only employees" do
        expect(User.all_employee).to include(user2, user4)
      end
    end
    
    context "when admin & hr" do
      it "exclude admin & hr's" do
        expect(User.all_employee).to_not include(user1, user3)
      end
    end
  end

  #Instance ethod test
  describe "#valid_dob?" do
    context "with valid DOB" do
      it "is expected to validate that :dob is valid" do
        user2.dob = "01-01-2009"
        expect(user2.send(:valid_dob?)).to eq(["#{user2.dob} is invalid. DOB should be before #{18.years.ago.to_date}"])
      end
    end
    
    context "with invalid DOB" do
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
    context "with selected user" do
      it "returns all userrs except given user" do
        expect(User.all_except(user2)).to include(user1, user3, user4)
      end
    end

    context "With not selected user" do
      it "returns all userrs except given user" do
        expect(User.all_except(user2)).to_not include(user2)
      end
    end
  end

  describe "#from_omniauth" do
    context "with registered user" do
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

    context "with non registerd user" do
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
    context "with no paramiter & user type Admin" do
      it "is expected to display all users" do
        expect(User.filter_by_role("", user1)).to include(user1, user2, user3, user4)
      end
    end
    
    context "with Admin paramiter & user type Admin" do
      it "is expected to display Admin users" do
        expect(User.filter_by_role("Admin", user1)).to include(user1)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("Admin", user1)).to_not include(user2, user3, user4)
      end
    end
    
    context "with HR paramiter & user type Admin" do
      it "is expected to display HR users" do
        expect(User.filter_by_role("HR", user1)).to include(user3)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("HR", user1)).to_not include(user1, user2, user4)
      end
    end
    
    context "with Employee paramiter & user type Admin" do
      it "is expected to display Employee users" do
        expect(User.filter_by_role("Employee", user1)).to include(user2, user4)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("Employee", user1)).to_not include(user1, user3)
      end
    end

    context "with no paramiter & user type HR" do
      it "is expected to display all users expect admin" do
        expect(User.filter_by_role("", user3)).to include(user2, user3, user4)
      end

      it "is expect not to display Admin users" do
        expect(User.filter_by_role("", user3)).to_not include(user1)
      end
    end

    context "with HR paramiter & user type HR" do
      it "is expected to display HR users" do
        expect(User.filter_by_role("HR", user3)).to include(user3)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("HR", user3)).to_not include(user1, user2, user4)
      end
    end

    context "with Employee paramiter & user type HR" do
      it "is expected to display Employee users" do
        expect(User.filter_by_role("Employee", user3)).to include(user2, user4)
      end

      it "is expected not to display other users" do
        expect(User.filter_by_role("Employee", user3)).to_not include(user1, user3)
      end
    end
  end
end
