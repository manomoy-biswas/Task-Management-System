require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do

  describe "#total_user" do
    context "for counting users" do
      it "is expected to return total no of user" do
        user1 = create(:admin, name: "Manomoy Biswas")
        user2 = create(:employee)
        user3 = create(:hr)
        expect(helper.total_users).to eq(3)
      end
    end
  end
end
