require 'rails_helper'

RSpec.describe UserMailerWorker, type: :worker do
  let (:user1) {create(:employee)}
  
  describe "#perform" do
    it "is expected to send a welcome email" do
      UserMailerWorker.new.perform(user1.id)
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end
  end
end
