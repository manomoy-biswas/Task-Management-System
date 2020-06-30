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
  
  # describe "#logged_in?" do
  #   context "when loggind in " do
  #     it "is expected to return true" do
  #       session[:user_id] = user1.id
  #       # allow(helper).to receive(:current_user).and_return(user1)
  #       expect(helper.logged_in?).to eq(true)
  #     end
  #   end
  #   context "when not logged in" do
  #     it "is expected to return false" do
  #       expect(helper.logged_in?).to eq(false)
  #     end
  #   end
  # end
  
  # describe "#admin?" do
  #   context "when current user is admin" do
  #     it "is expected to return true" do
  #       allow(helper).to receive(:current_user).and_return(user1)
  #       expect(helper.admin?).to eq(true)
  #     end
  #   end
  #   context "when current user is not an admin" do
  #     it "is expected to return false" do
  #       allow(helper).to receive(:current_user).and_return(user2)
  #       expect(helper.admin?).to eq(false)
  #     end
  #   end
  # end
  
  # describe "#hr?" do
  #   context "when current user is a HR" do
  #     it "is expected to return true" do
  #       allow(helper).to receive(:current_user).and_return(user2)
  #       expect(helper.hr?).to eq(true)
  #     end
  #   end
  #   context "when current user is not a HR" do
  #     it "is expected to return false" do
  #       allow(helper).to receive(:current_user).and_return(user1)
  #       expect(helper.hr?).to eq(false)
  #     end
  #   end
  # end
end
