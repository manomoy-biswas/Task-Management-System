require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let (:user1) {create(:admin)}
  let (:user2) {create(:hr)}
  describe "#full_title" do
    it "is expected to return full title" do
      expect(helper.full_title("Task")).to eq("Task | Task Management System")
    end
    it "is expected to return full title" do
      expect(helper.full_title).to eq("Task Management System")
    end
  end
  describe "#logged_in?" do
    it "is expected to return true" do
      allow(helper).to receive(:current_user).and_return(user1)
      expect(helper.logged_in?).to eq(true)
    end
    it "is expected to return false" do
      expect(helper.logged_in?).to eq(false)
    end
  end
  describe "#admin?" do
    it "is expected to return true" do
      allow(helper).to receive(:current_user).and_return(user1)
      expect(helper.admin?).to eq(true)
    end
    it "is expected to return false" do
      allow(helper).to receive(:current_user).and_return(user2)
      expect(helper.admin?).to eq(false)
    end
  end
  describe "#hr?" do
    it "is expected to return true" do
      allow(helper).to receive(:current_user).and_return(user2)
      expect(helper.hr?).to eq(true)
    end
    it "is expected to return false" do
      allow(helper).to receive(:current_user).and_return(user1)
      expect(helper.hr?).to eq(false)
    end
  end
end
