require "rails_helper"

RSpec.describe Task, type: :model do
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:employee)}
  let (:user4) {create(:employee)}
  let (:user5) {create(:hr)}
  let (:category1) {create(:category)}
  subject { create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, priority: "Medium", assign_task_by: user1.id, approved: true)}
  let (:task2) { create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, priority: "High")}
  let (:task3) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, approved: true, priority: "Low", notify_hr: true)}
  let (:task4) { create(:assigned_task2, task_category: category1.id, assign_task_to: user4.id, assign_task_by: user2.id, approved: true, priority: "Medium")}
  let (:task5) { create(:assigned_task2, task_category: category1.id, assign_task_to: user4.id, assign_task_by: user2.id, approved: true, priority: "High", notify_hr: true)}
  let (:task6) { create(:assigned_task2, task_category: category1.id, assign_task_to: user4.id, assign_task_by: user2.id, approved: true, priority: "Low", notify_hr: true)}

  context "Association tests:" do
    describe "has_many :sub_task" do
      it { is_expected.to have_many(:sub_task).dependent(:destroy) }
    end
    describe "has_many :notification" do
      it { is_expected.to have_many(:notification).with_foreign_key("notifiable_id").dependent(:destroy) }
    end
    describe "has_many :task_document" do
      it { is_expected.to have_many(:task_document).dependent(:destroy) }
    end
    describe "belongs_to :category" do
      it { is_expected.to belong_to(:category).with_foreign_key("task_category") }
    end
    describe "belongs_to :user" do
      it { is_expected.to belong_to(:user).with_foreign_key("assign_task_to") }
    end
    describe "belongs_to :assign_by" do
      it { is_expected.to belong_to(:assign_by).class_name("User").with_foreign_key("assign_task_by") }
    end
  end

  context "Validation tests" do
    describe "validate_presence_of(:task_name)" do
      it { is_expected.to validate_presence_of(:task_name)}
    end
    describe "validate_presence_of(:priority)" do
      it { is_expected.to validate_presence_of(:priority)}
    end
    describe "validate_presence_of(:task_category)" do
      it { is_expected.to validate_presence_of(:task_category)}
    end
    describe "validate_presence_of(:repeat)" do
      it { is_expected.to validate_presence_of(:repeat)}
    end
    describe "validate_presence_of(:assign_task_to)" do
      it { is_expected.to validate_presence_of(:assign_task_to)}
    end
    describe "validate_uniqueness_of(:task_name)" do
      it { is_expected.to validate_uniqueness_of(:task_name).case_insensitive}
    end
    describe "validate_length_of(:task_name)" do
      it { is_expected.to validate_length_of(:task_name).is_at_most(255) }
    end
    describe "validate_inclusion_of(:priority)" do
      it { is_expected.to validate_inclusion_of(:priority).in_array(%w[High Medium Low]) }
    end
    describe "validate_inclusion_of(:repeat)" do
      it { is_expected.to validate_inclusion_of(:repeat).in_array(%w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]) }
    end
    describe "accept_nested_attributes_for(:sub_task)" do
      it {is_expected.to accept_nested_attributes_for(:sub_task).allow_destroy(true) }
    end
  end

  context "Callback tests:" do
    describe "after_commit :index_task" do
      it {is_expected.to callback(:index_task).after(:commit)}
    end
    describe "after_commit :delete_task_index" do
      it {is_expected.to callback(:delete_task_index).after(:commit)}
    end
    describe "after_create :task_reminder_email" do
      it {is_expected.to callback(:task_reminder_email).after(:create)}
    end
    describe "after_create :task_create_email" do
      it {is_expected.to callback(:task_create_email).after(:create)}
    end
    describe "after_create :task_create_notification" do
      it {is_expected.to callback(:task_create_notification).after(:create)}
    end
    describe "before_validation :squeeze_task_name" do
      it {is_expected.to callback(:squeeze_task_name).before(:validation)}
    end
  end

  #Scope test
  context "Scope tests:" do
    describe ".my_assigned_tasks" do
      it "includes task assigned by me" do
        expect(Task.my_assigned_tasks(user1.id)).to include(subject, task1)
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
        expect(Task.notified_tasks).to include(task3, task6)
      end
    end
    describe ".notified_tasks_filter" do
      it "includes task notified by admin filter by priority" do
        expect(Task.notified_tasks_filter("Low")).to include(task3)
      end
    end
    describe ".admin_task_filter" do
      it "includes admin task filter by priority" do
        expect(Task.admin_task_filter("High")).to include(task2, task5)
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

  #Instance Method test
  context "Instance Method test:" do
    describe "#squeeze_task_name" do
      it "task name should remove extra space and capitalize when validated" do
        subject.task_name="  Birth  day celebration "
        expect(subject.send(:squeeze_task_name)).to eq("Birth day celebration")
      end
    end
    describe "#valid_submit_date" do
      it "is expected to validate that :submit_date is valid" do
        subject.submit_date = "2020-06-14 03:27:00.0"
        expect(subject.send(:valid_submit_date)).to eq(["Submit date can't be assign to a previous date/time."])
      end
      it "is expected to validate that :submit_date can't blank" do
        subject.submit_date = ""
        expect(subject.send(:valid_submit_date)).to eq(["Submit date can't be blank"])
      end
    end
    describe "#valid_updated_submit_date" do
      it "is expected to validate that :submit_date is valid when update" do
        subject.submit_date = "2020-06-14 03:27:00.0"
        expect(subject.send(:valid_updated_submit_date)).to eq(["Submit date must be greated that created date"])
      end
      it "is expected to validate that :submit_date can't blank when update" do
        subject.submit_date = ""
        expect(subject.send(:valid_updated_submit_date)).to eq(["Submit date can't be blank"])
      end
    end
  end
  # Class Method Test
  context "Class method tests:" do
    # describe "#task_search" do
      # it "is expected to search tasks for a employee user" do
      #   task1.task_name = "Lorem Ipsum"
      #   task2.task_name = "Lorem Ipsum Sit"
      #   task3.task_name = "Unknown Task"
      #   expect(Task.task_search("Lorem", user2)).to include(task1, task2)
      # end
      # it "is expected to search tasks for a admin user" do
      #   task1.task_name = "Lorem Ipsum"
      #   task2.task_name = "Lorem Ipsum Sit"
      #   task3.task_name = "Unknown Task"
      #   expect(Task.task_search("Lorem", user1)).to include(subject, task2, task3, task4)
      # end
    # end
    describe "#filter_by_priority" do
      it "Display All tas for paramiter = '' and user_role = 'Admin'" do
        expect(Task.filter_by_priority("", user1)).to include(task6, task5, task4, task3, task2, task1)
      end

      it "Display Medium priority task for paramiter = 'Medium' and user_role = 'Admin'" do

        expect(Task.filter_by_priority("Medium", user1)).to include(task1, task4)
      end

      it "Not display non Medium priority task for paramiter = 'Medium' and user_role = 'Admin'" do
        expect(Task.filter_by_priority("Medium", user1)).to_not include(task6, task5, task3, task2)
      end

      it "Display Low priority task for paramiter = 'Low' and user_role = 'Admin'" do
        expect(Task.filter_by_priority("Low", user1)).to include(task6, task3)
      end

      it "Not display non Low priority task for paramiter = 'Low' and user_role = 'Admin'" do
        task1.priority = "Low"
        expect(Task.filter_by_priority("Low", user1)).to_not include(task5, task4, task2, task1)
      end

      it "Display High priority task for paramiter = 'High' and user_role = 'Admin'" do
        expect(Task.filter_by_priority("High", user1)).to include(task5, task2)
      end

      it "Not display non High priority task for paramiter = 'High' and user_role = 'Admin'" do
        expect(Task.filter_by_priority("High", user1)).to_not include(task6, task4, task3, task1)
      end

      it "Display My task for paramiter = '' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("", user2)).to include(task1, task2, task3)
      end

      it "Not display others task for paramiter = '' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("", user2)).to_not include(task4, task5, task6)
      end

      it "Display Medium priority task for paramiter = 'Medium' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("Medium", user2)).to include( task1)
      end

      it "Display Medium priority task for paramiter = 'Medium' and user_role = 'Employee1'" do
        expect(Task.filter_by_priority("Medium", user4)).to include( task4)
      end

      it "Not display others Medium priority task for paramiter = 'Medium' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("Medium", user2)).to_not include(task4)
      end

      it "Not display others Medium priority task for paramiter = 'Medium' and user_role = 'Employee1'" do
        expect(Task.filter_by_priority("Medium", user4)).to_not include(task1)
      end

      it "Display Low priority task for paramiter = 'Low' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("Low", user2)).to include( task3)
      end

      it "Not display others non Low priority task for paramiter = 'Low' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("Low", user2)).to_not include(task6)
      end

      it "Display High priority task for paramiter = 'High' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("High", user2)).to include(task2)
      end

      it "Not display others non High priority task for paramiter = 'High' and user_role = 'Employee'" do
        expect(Task.filter_by_priority("High", user2)).to_not include(task5)
      end
    end

    describe "#filter_approved_task_by_priority" do
      it "includes all approved task for param = '' and user_role ='Admin'" do
        expect(Task.filter_approved_task_by_priority("", user1)).to include(task1, task3, task4, task6)
      end

      it "includes all approved task for param = '' and user_role ='HR'" do
        expect(Task.filter_approved_task_by_priority("", user5)).to include(task3, task6)
      end

      it "includes all approved task for param = 'Low' and user_role ='Admin'" do
        expect(Task.filter_approved_task_by_priority("Low", user1)).to include(task3, task6)
      end

      it "includes all approved task for param = 'Low' and user_role ='HR'" do
        expect(Task.filter_approved_task_by_priority("Low", user5)).to include(task3, task6)
      end

      it "includes all approved task for param = 'Medium' and user_role ='Admin'" do
        expect(Task.filter_approved_task_by_priority("Medium", user1)).to include(task1, task4)
      end

      it "includes all approved task for param = 'Medium' and user_role ='HR'" do
        expect(Task.filter_approved_task_by_priority("Medium", user5)).to_not include(task1, task3)
      end
      
      it "includes all approved task for param = 'High' and user_role ='Admin'" do
        expect(Task.filter_approved_task_by_priority("High", user1)).to_not include(task1, task3, task4, task6)
      end

      it "includes all approved task for param = 'Medium' and user_role ='HR'" do
        expect(Task.filter_approved_task_by_priority("High", user5)).to_not include(task3, task6)
      end
    end

    describe "#filter_user_assigned_task_by_priority" do

      it "Display All user assignrd task for paramiter = ''" do
        expect(Task.filter_user_assigned_task_by_priority("", user1)).to include(task1)
      end

      it "Display Medium priority task for paramiter = 'Medium'" do
        expect(Task.filter_user_assigned_task_by_priority("Medium", user2)).to include(task4)
      end

      it "Not display non Medium priority task for paramiter = 'Medium'" do
        expect(Task.filter_user_assigned_task_by_priority("Medium", user2)).to_not include(task6, task5)
      end

      it "Display Low priority task for paramiter = 'Low' and user_role = 'Admin'" do
        expect(Task.filter_user_assigned_task_by_priority("Low", user3)).to include(task3)
      end

      it "Not display non Low priority task for paramiter = 'Low'" do
        expect(Task.filter_user_assigned_task_by_priority("Low", user3)).to_not include(task2)
      end

      it "Display High priority task for paramiter = 'High' and user_role = 'Admin'" do
        expect(Task.filter_user_assigned_task_by_priority("High", user2)).to include(task5)
      end

      it "Not display non High priority task for paramiter = 'High' and user_role = 'Admin'" do
        expect(Task.filter_user_assigned_task_by_priority("High", user2)).to_not include(task6, task4)
      end
    end
  end
end