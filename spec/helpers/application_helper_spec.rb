require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let (:user1) {create(:admin)}
  let (:user2) {create(:hr)}
  
  describe "#full_title" do
    context "with no argument" do
      it "is expected to return full title" do
        expect(helper.full_title).to eq("Task Management System")
      end
    end
    context "with argument" do
      it "is expected to return full title with aurgument" do
        expect(helper.full_title("Task")).to eq("Task | Task Management System")
      end
    end
  end
end
