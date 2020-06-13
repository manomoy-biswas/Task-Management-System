require "rails_helper"

RSpec.describe SubTask, type: :model do
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:employee)}
  let (:category1) {create(:category)}
  subject { create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, approved: true)}
  let (:task2) { create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, priority: "High")}
  let (:task3) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, approved: true, priority: "Low", notify_hr: true)}
  let (:task4) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, approved: true, priority: "Medium", notify_hr: true)}

  context "Association tests:" do
    it { is_expected.to have_many(:sub_task).dependent(:destroy) }
    it { is_expected.to have_many(:notification).with_foreign_key("notifiable_id").dependent(:destroy) }
    it { is_expected.to have_many(:task_document).dependent(:destroy) }
    it { is_expected.to belong_to(:category).with_foreign_key("task_category") }
    it { is_expected.to belong_to(:user).with_foreign_key("assign_task_to") }
    it { is_expected.to belong_to(:assign_by).class_name("User").with_foreign_key("assign_task_by") }
  end

  context "Validation tests" do
    it { is_expected.to validate_presence_of(:task_name)}
    it { is_expected.to validate_presence_of(:priority)}
    it { is_expected.to validate_presence_of(:task_category)}
    it { is_expected.to validate_presence_of(:repeat)}
    it { is_expected.to validate_presence_of(:assign_task_to)}
    it { is_expected.to validate_presence_of(:submit_date)}
    it { is_expected.to validate_uniqueness_of(:task_name).case_insensitive}
    it { is_expected.to validate_length_of(:task_name).is_at_most(255) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w[High Medium Low]) }
    it { is_expected.to validate_inclusion_of(:repeat).in_array(%w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]) }
    it {is_expected.to accept_nested_attributes_for(:sub_task).allow_destroy(true) }
  end

  context "Scope tests:" do
    describe ".my_assigned_tasks" do
      it "includes task assigned by me" do
        expect(Task.my_assigned_tasks(user1.id)).to include(subject)
      end
    end
    describe ".my_assigned_tasks_filter" do
      it "includes task assigned by me filtered by priority" do
        expect(Task.my_assigned_tasks_filter("High", user3.id,)).to include(task2)
      end
    end
    describe ".approved_tasks" do
      it "includes approved task" do
        expect(Task.approved_tasks).to include(task1)
      end
    end
    describe ".approved_tasks_filter" do
      it "includes approved task filter by priority" do
        expect(Task.approved_tasks_filter("Low")).to include(task3)
      end
    end
    describe ".notified_tasks" do
      it "includes task notified by admin" do
        expect(Task.notified_tasks).to include(task3, task4)
      end
    end
    describe ".notified_tasks_filter" do
      it "includes task notified by admin filter by priority" do
        expect(Task.notified_tasks_filter("Low")).to include(task3)
      end
    end
    describe ".admin_task_filter" do
      it "includes admin task filter by priority" do
        expect(Task.admin_task_filter("High")).to include(task2)
      end
    end
    describe ".my_task_filter" do
      it "includes my task filter by priority" do
        expect(Task.my_task_filter("High", user2.id)).to include(task2)
      end
    end
    describe ".recurring_task" do
      it "includes my task filter by priority" do
        expect(Task.recurring_task).to include(task3, task4)
      end
    end
  end
end