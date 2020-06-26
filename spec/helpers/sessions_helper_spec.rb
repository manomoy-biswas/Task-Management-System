require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let (:user1) {create(:admin)}
  describe "#login" do
    context "for login a user" do
      it "is expected to return session user id" do
        helper.login(user1)
        expect(session[:user_id]).to eq(user1.id)
      end
    end
  end

  describe "#logout" do
    context "for logout" do
      it "is expected to return nil" do
        helper.logout
        expect(session[:user_id]).to eq(nil)
      end
    end
  end

  describe "#current_user" do
    context "for current user" do
      it "is expected to return current_user" do
        helper.login(user1)
        expect(helper.current_user.id).to eq(user1.id)
      end
    end
    context "for not current user" do
      it "is expected to return current_user nil" do
        expect(helper.current_user).to eq(nil)
      end
    end    
  end
end