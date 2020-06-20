require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  let (:user1) { create(:employee) }
  let (:user2) { create(:hr) }
  let (:user3) { create(:admin) }

  context "Method test" do
    describe "#authenticate_user!" do
      it "is expected to redirect to root path" do
        expect(controller).to receive(:redirect_to).with(root_path, {:flash=> {:danger=> "you are already logged in / Please login with your credential."}})
        controller.send(:authenticate_user!)
      end

      it "is expected to not redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user1)
        expect(controller).to_not receive(:redirect_to).with(root_path, {:flash=> {:danger=> "you are already logged in / Please login with your credential."}})
        controller.send(:authenticate_user!)
      end

    end

    describe "#check_user_is_hr" do
      it "is expected to redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user2)
        expect(controller).to receive(:redirect_to).with(users_dashboard_path, {:flash=> {:warning=>"You are not a HR. Only HR has right login here."}})
        controller.send(:check_user_is_hr)
      end

      it "is expected to not redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user1)
        expect(controller).to_not receive(:redirect_to).with(users_dashboard_path, {:flash=> {:warning=>"You are not a HR. Only HR has right login here."}})
        controller.send(:check_user_is_hr)
      end

    end
    describe "#check_user_is_admin" do
      it "is expected to redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user3)
        expect(controller).to_not receive(:redirect_to).with(root_path, {:flash=> {:warning=>"You are not a ADMIN. Only ADMIN has right to login here."}})
        controller.send(:check_user_is_admin)
      end

      it "is expected to redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user1)
        expect(controller).to receive(:redirect_to).with(root_path, {:flash=> {:warning=>"You are not a ADMIN. Only ADMIN has right to login here."}})
        controller.send(:check_user_is_admin)
      end

    end
  end


end
