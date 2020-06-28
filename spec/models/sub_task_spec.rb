require "rails_helper"

RSpec.describe SubTask, type: :model do
  let (:user1) { create(:admin) } 
  let (:user2) { create(:employee) }
  let (:category1) { create(:category) }
  let (:task1) {create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
  let (:task2) {create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
  let! (:subtask1) {create(:assigned_subtask, task_id: task1.id)}
  let! (:subtask2) {create(:assigned_subtask, task_id: task1.id, submit: true)}
  
  describe "Model Assiciation test" do
    it { is_expected.to belong_to(:task) }
  end

  describe "Model Validation test" do
    it { is_expected.to validate_presence_of(:name)}
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(255) }
  end

  describe ".find_subtasks" do
    context "when subtask availabe" do
      it "is expected to includes all subtask of a task" do
        expect(SubTask.find_subtasks(task1.id)).to include(subtask1, subtask2)
      end
    end
    context "when subtask not availabe" do
      it "is expected to return nil" do
        expect(SubTask.find_subtasks(task2.id)).to eq([])
      end
    end
  end
  describe ".find_not_submitted_subtasks" do
    context "when subtask not submitted" do
      it "includes all not submitted subtask of a task" do
        expect(SubTask.find_not_submitted_subtasks(task1.id)).to include(subtask1)
      end
    end
    context "when subtask submitted" do
      it "includes all not submitted subtask of a task" do
        expect(SubTask.find_not_submitted_subtasks(task1.id)).to_not include(subtask2)
      end
    end
  end

  describe "#all_subtasks_submitted" do
    context "when all subtask submitted" do
      it "it expected to return true" do
        expect(SubTask.all_subtasks_submitted(task2)).to eq(true)
      end
    end
    context "when all subtask not submitted" do
      it "it expected to return false" do
        expect(SubTask.all_subtasks_submitted(task1)).to eq(false)
      end
    end
  end
end
