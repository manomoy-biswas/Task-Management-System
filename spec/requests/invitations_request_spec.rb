require 'rails_helper'

RSpec.describe "Invitations", type: :request do

  describe "GET /edit" do
    it "returns http success" do
      get "/invitations/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/invitations/new"
      expect(response).to have_http_status(:success)
    end
  end

end
