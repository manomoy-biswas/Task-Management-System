require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  let (:user1) { create(:employee) }
  let (:user2) { create(:hr) }
  let (:user3) { create(:admin) }

  #method test
  describe "#authenticate_user!" do
    context "with authentication error" do
      it "is expected to redirect to root path" do
        expect(controller).to receive(:redirect_to).with(root_path, {:flash=> {:danger=> "you are already logged in / Please login with your credential."}})
        controller.send(:authenticate_user!)
      end
    end

    context "with successfull authentication" do
      it "is expected to not redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user1)
        expect(controller).to_not receive(:redirect_to).with(root_path, {:flash=> {:danger=> "you are already logged in / Please login with your credential."}})
        controller.send(:authenticate_user!)
      end
    end
  end

  describe "#check_user_is_hr" do\
    context "when not HR" do
      it "is expected to redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user2)
        expect(controller).to receive(:redirect_to).with(users_dashboard_path, {:flash=> {:warning=>"You are not a HR. Only HR has right login here."}})
        controller.send(:check_user_is_hr)
      end
    end

    context "when HR" do
      it "is expected to not redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user1)
        expect(controller).to_not receive(:redirect_to).with(users_dashboard_path, {:flash=> {:warning=>"You are not a HR. Only HR has right login here."}})
        controller.send(:check_user_is_hr)
      end
    end
  end

  describe "#check_user_is_admin" do
    context "When not Admin" do
      it "is expected to redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user3)
        expect(controller).to_not receive(:redirect_to).with(root_path, {:flash=> {:warning=>"You are not a ADMIN. Only ADMIN has right to login here."}})
        controller.send(:check_user_is_admin)
      end
    end

    context "when admin" do
      it "is expected to redirect to root path" do
        allow(controller).to receive(:current_user).and_return(user1)
        expect(controller).to receive(:redirect_to).with(root_path, {:flash=> {:warning=>"You are not a ADMIN. Only ADMIN has right to login here."}})
        controller.send(:check_user_is_admin)
      end
    end
  end

  describe "#current_user" do
    context "with current user" do
      it "is expected to return current_user" do
        session[:user_id] = user1.id
        expect(controller.current_user.id).to eq(user1.id)
      end
    end

    context "with no current user" do
      it "is expected to return current_user nil" do
        expect(controller.current_user).to eq(nil)
      end
    end    
  end

  describe "#logged_in?" do
    context "when loggind in " do
      it "is expected to return true" do
        session[:user_id] = user1.id
        # allow(controller).to receive(:current_user).and_return(user1)
        expect(controller.logged_in?).to eq(true)
      end
    end
    context "when not logged in" do
      it "is expected to return false" do
        expect(controller.logged_in?).to eq(false)
      end
    end
  end
  
  describe "#admin?" do
    context "when current user is admin" do
      it "is expected to return true" do
        session[:user_id] = user3.id
        # allow(controller).to receive(:current_user).and_return(user1)
        expect(controller.admin?).to eq(true)
      end
    end
    context "when current user is not an admin" do
      it "is expected to return false" do
        session[:user_id] = user2.id
        # allow(controller).to receive(:current_user).and_return(user2)
        expect(controller.admin?).to eq(false)
      end
    end
  end
  
  describe "#hr?" do
    context "when current user is a HR" do
      it "is expected to return true" do
        session[:user_id] = user2.id
        # allow(controller).to receive(:current_user).and_return(user2)
        expect(controller.hr?).to eq(true)
      end
    end
    context "when current user is not a HR" do
      it "is expected to return false" do
        session[:user_id] = user1.id
        # allow(controller).to receive(:current_user).and_return(user1)
        expect(controller.hr?).to eq(false)
      end
    end
  end
end
