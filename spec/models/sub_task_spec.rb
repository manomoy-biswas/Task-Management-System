require "rails_helper"

RSpec.describe SubTask, type: :model do
  let (:user1) { create(:admin) } 
  let (:user2) { create(:employee) }
  let (:category1) { create(:category) }
  let (:task) {create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
  let (:subtask1) {create(:assigned_subtask, task_id: task.id)}
  let (:subtask2) {create(:assigned_subtask, task_id: task.id, submit: true)}
  
  context "Assiciation tests:" do
    it { is_expected.to belong_to(:task) }
  end

  context "Validation tests:" do
    it { is_expected.to validate_presence_of(:name)}
    it { is_expected.to validate_length_of(:name).is_at_least(3).is_at_most(255) }
  end

  context "Scope tests" do
    describe ".find_subtasks" do
      it "includes all subtask of a task" do
        expect(SubTask.find_subtasks(task.id)).to include(subtask1, subtask2)
      end
    end
    describe ".find_not_submitted_subtasks" do
      it "includes all not submitted subtask of a task" do
        expect(SubTask.find_not_submitted_subtasks(task.id)).to include(subtask1)
      end
    end
  end

  context "Method tests" do
    describe "#all_subtasks_submitted" do
      it "return true if all subtasks are submitted" do
        expect(SubTask.all_subtasks_submitted(task)).to eq(true)
      end
    end
  end


end
