require 'rails_helper'

RSpec.describe NotificationsChannel, type: :channel do
  let (:user1) {create(:employee)}
  
  before { stub_connection current_user: user1 }
  
  describe "#subscribed" do
    it "successfully subscribes" do
      subscribe()
      expect(subscription).to have_stream_from("notifications_channel_#{user1.id}")
    end
  end
  
  describe "#unsubscribed" do
    it "is extected to successfully unsubscribed" do
      subscribe()
      unsubscribe
      expect(subscription).to_not have_streams
    end
  end
end