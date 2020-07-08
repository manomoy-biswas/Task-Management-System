require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let (:user1) {create(:admin)}
  describe "#login" do
    context "when login a user" do
      it "is expected to return session user id" do
        helper.login(user1)
        expect(session[:user_id]).to eq(user1.id)
      end
    end
  end

  describe "#logout" do
    context "when logout" do
      it "is expected to return nil" do
        helper.logout
        expect(session[:user_id]).to eq(nil)
      end
    end
  end
end