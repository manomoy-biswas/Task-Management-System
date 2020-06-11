require 'rails_helper'

RSpec.describe User, type: :model do
  context "validation tests:" do
    let (:user){ User.new(name: Faker::Name.name, email: "manomoybiswas1414@gmail.com", phone: "7894561232", dob: "10-09-1995") }
    it "ensure name present" do
      user.name=nil
      expect(user).to_not be_valid
    end

    it "ensure email present" do
      user.email=nil
      expect(user).to_not be_valid
    end

    it "ensure phone no present" do
      user.phone = nil
      expect(user).to_not be_valid
    end

    it "ensure dob present" do
      user.dob=""
      expect(user).to_not be_valid
    end

    it "ensure save succesfully" do
      expect(user).to be_valid
    end
    
    
  end

  context "scope tests:" do
  end
end
