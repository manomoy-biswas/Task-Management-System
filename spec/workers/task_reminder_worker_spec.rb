require 'rails_helper'

RSpec.describe TaskReminderWorker, type: :worker do
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:category1) {create(:category)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id, submit: true, approved: true, priority: "Low", notify_hr: false, approved_by: user1.id)}
  let (:task2) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id, approved: true, priority: "Low")}
  
  describe "#perform" do
    context "for task reminder" do
      it "is expected to send an email" do
        TaskReminderWorker.new.perform(task2.id)
        expect(ActionMailer::Base.deliveries.length).to eq(1)
      end
    end
    
    context "for not task reminder" do
      it "is expected to not send an email" do
        TaskReminderWorker.new.perform(task1.id)
        expect(ActionMailer::Base.deliveries.length).to eq(0)
      end
    end
  end
end
