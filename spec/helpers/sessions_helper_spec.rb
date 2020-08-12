require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let (:user1) {create(:admin)}
  # describe "#login" do
  #   context "when login a user" do
  #     it "is expected to return session user id" do
  #       @request.host = "localhost:3000"
  #       helper.login(user1)
  #       expect(cookies[:auth_token]).to eq(user1.auth_token)
  #     end
  #   end
  # end

  describe "#logout" do
    context "when logout" do
      it "is expected to return nil" do
        helper.logout
        expect(cookies[:auth_token]).to eq(nil)
      end
    end
  end
end