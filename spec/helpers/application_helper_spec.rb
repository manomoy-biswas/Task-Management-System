require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let (:user1) {create(:admin)}
  let (:user2) {create(:hr)}
  let (:user2) {create(:employee)}
  let (:category1) {create(:category)}
  let (:category2) {create(:category)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user3.id, priority: "Medium", assign_task_by: user1.id, approved: true)}
  let (:task2) { create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id, priority: "High")}
  let (:task3) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id, approved: true, priority: "Low", notify_hr: true)}
  
  describe "#full_title" do
    context "with no argument" do
      it "is expected to return full title" do
        expect(helper.full_title).to eq("Task Management System")
      end
    end
    context "with argument" do
      it "is expected to return full title with aurgument" do
        expect(helper.full_title("Task")).to eq("Task | Task Management System")
      end
    end
  end
end
