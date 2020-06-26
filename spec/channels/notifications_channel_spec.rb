require 'rails_helper'

RSpec.describe NotificationsChannel, type: :channel do
  let (:user1) { create(:employee) }
  let (:user2) { create(:employee) }
  
  before { stub_connection current_user: user1 }
  
  describe "#subscribed" do
    context "for subscribed" do
      it "successfully subscribes" do
        subscribe()
        expect(subscription).to have_stream_from("notifications_channel_#{user1.id}")
      end
    end 
    context "for not subscribed" do
      it "is expexted to not subscribe" do
        subscribe()
        expect(subscription).to_not have_stream_from("notifications_channel_#{user2.id}")
      end
    end 
  end
  
  describe "#unsubscribed" do
    context "for unsubscribe channel" do
      it "is extected to successfully unsubscribed" do
        subscribe()
        unsubscribe
        expect(subscription).to_not have_streams
      end
    end
  end
end