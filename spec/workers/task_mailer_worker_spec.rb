require 'rails_helper'

RSpec.describe TaskMailerWorker, type: :worker do
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:category1) {create(:category)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id, approved: true, priority: "Low", notify_hr: true, approved_by: user1.id)}
  describe "#perform" do
    it "is expected to send an create email" do
      TaskMailerWorker.new.perform(task1.id, "create")
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end
    it "is expected to send an update email" do
      TaskMailerWorker.new.perform(task1.id, "update")
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end
    it "is expected to send an approved email" do
      TaskMailerWorker.new.perform(task1.id, "approved")
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end
    it "is expected to send an approved by email" do
      TaskMailerWorker.new.perform(task1.id, "approved by")
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end
    it "is expected to send an reminder email" do
      TaskMailerWorker.new.perform(task1.id, "reminder")
      expect(ActionMailer::Base.deliveries.length).to eq(1)
    end
  end
end