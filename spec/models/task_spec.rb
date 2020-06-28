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

  # Association test
  describe "Model Association test" do
    it { is_expected.to have_many(:sub_task).dependent(:destroy) }
    it { is_expected.to have_many(:notification).with_foreign_key("notifiable_id").dependent(:destroy) }
    it { is_expected.to have_many(:task_document).dependent(:destroy) }
    it { is_expected.to belong_to(:category).with_foreign_key("task_category") }
    it { is_expected.to belong_to(:user).with_foreign_key("assign_task_to") }
    it { is_expected.to belong_to(:assign_by).class_name("User").with_foreign_key("assign_task_by") }
  end

  # Validation test
  describe "Model validation test" do
    it { is_expected.to validate_presence_of(:task_name)}
    it { is_expected.to validate_presence_of(:priority)}
    it { is_expected.to validate_presence_of(:task_category)}
    it { is_expected.to validate_presence_of(:repeat)}
    it { is_expected.to validate_presence_of(:assign_task_to)}
    it { is_expected.to validate_uniqueness_of(:task_name).case_insensitive}
    it { is_expected.to validate_length_of(:task_name).is_at_most(255) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w[High Medium Low]) }
    it { is_expected.to validate_inclusion_of(:repeat).in_array(%w[One_Time Daily Weekly Monthly Quarterly Half_yearly Yearly]) }
    it {is_expected.to accept_nested_attributes_for(:sub_task).allow_destroy(true) }
  end

  # Callback test
  context "callbacks" do
    it {is_expected.to callback(:index_task).after(:commit)}
    it {is_expected.to callback(:delete_task_index).after(:commit)}
    it {is_expected.to callback(:task_reminder_email).after(:create)}
    it {is_expected.to callback(:task_create_email).after(:create)}
    it {is_expected.to callback(:task_create_notification).after(:create)}
    it {is_expected.to callback(:squeeze_task_name).before(:validation)}
  end

  # Scope test
  describe ".my_assigned_tasks" do
    context "with valid task" do
      it "is extected to include task assigned by me" do
        expect(Task.my_assigned_tasks(user1.id)).to include(subject, task1)
      end
    end
    
    context "with invalid task" do
      it "is extected to exclude task assigned by me" do
        expect(Task.my_assigned_tasks(user1.id)).to_not include(task2, task3, task4, task5, task6)
      end
    end
  end
  
  describe ".my_assigned_tasks_filter" do
    context "with valid task" do
      it "is expected to include task assigned by me by priority" do
        expect(Task.my_assigned_tasks_filter("High", user3.id,)).to include(task2)
      end
    end
    
    context "with invalid task" do
      it "is expected to excludes task assigned by me by priority" do
        expect(Task.my_assigned_tasks_filter("High", user3.id,)).to_not include(subject, task1, task3, task4, task5, task5)
      end
    end
  end
  
  describe ".approved_tasks" do
    context "with valid task" do
      it "is expected to include approved task" do
        expect(Task.approved_tasks).to include(task1, task3, task4, task5, task6)
      end
    end
  
    context "with invalid task" do
      it "is expected to exclude approved task" do
        expect(Task.approved_tasks).to_not include(subject, task2)
      end
    end
  end
  
  describe ".approved_tasks_filter" do
    context "with valid task" do
      it "is expected to include approved task by priority" do
        expect(Task.approved_tasks_filter("Low")).to include(task3, task6)
      end
    end
  
    context "with invalid task" do
      it "is expected to exclude approved task by priority" do
        expect(Task.approved_tasks_filter("Low")).to_not include(task1, task2, task4, task5)
      end
    end
  end
  
  describe ".notified_tasks" do
    context "with valid task" do
      it "is expected to include task notified by admin" do
        expect(Task.notified_tasks).to include(task3, task5, task6)
      end
    end
  
    context "with invalid task" do
      it "is expected to include task notified by admin" do
        expect(Task.notified_tasks).to_not include(task1, task2, task4)
      end
    end
  end
  
  describe ".notified_tasks_filter" do
    context "with valid task" do
      it "is expected to include notified task by low priority" do
        expect(Task.notified_tasks_filter("Low")).to include(task3, task6)
      end
    end
  
    context "with invalid task" do
      it "is expected to exclude notified task by low priority" do
        expect(Task.notified_tasks_filter("Low")).to_not include(task5)
      end
    end
  end
  
  describe ".admin_task_filter" do
    context "with valid task" do
      it "is expected to include admin task by priority" do
        expect(Task.admin_task_filter("High")).to include(task2, task5)
      end
    end
  
    context "with invalid task" do
      it "is expected to exclude admin task by priority" do
        expect(Task.admin_task_filter("High")).to_not include(task1, task3, task4, task6)
      end
    end
  end
  
  describe ".my_task_filter" do
    context "with valid task" do
      it "it is expected to include my task by priority" do
        expect(Task.my_task_filter("High", user2.id)).to include(task2)
      end
    end
  
    context "with invalid task" do
      it "it is expected to exclude my task by priority" do
        expect(Task.my_task_filter("High", user2.id)).to_not include(task5)
      end
    end
  end
  
  describe ".recurring_task" do
    context "with valid task" do
      it "is expected to include recurring task" do
        expect(Task.recurring_task).to include(task1, task3, task4, task5, task6)
      end
    end
  
    context "with invalid task" do
      it "is expected to exclude recurring task" do
        expect(Task.recurring_task).to_not include(subject, task2)
      end
    end
  end

  #Instance Method test
  describe "#squeeze_task_name" do
    context "when valid" do
      it "is expected to remove extra space and capitalize" do
        subject.task_name="  Birth  day celebration "
        expect(subject.send(:squeeze_task_name)).to eq("Birth day celebration")
      end
    end
  
    context "when invalid" do
      it "is expected not to be invalid" do
        subject.task_name="  Birth  day celebration "
        expect(subject.send(:squeeze_task_name)).to_not eq("birth  day  Celebration")
      end
    end
  end

  describe "#valid_submit_date" do
    context "with a date input" do
      it "is expected to be valid" do
        subject.submit_date = "2020-06-14 03:27:00.0"
        expect(subject.send(:valid_submit_date)).to eq(["Submit date can't be assign to a previous date/time."])
      end
    end
  
    context "with blank" do
      it "is expected to raise error" do
        subject.submit_date = ""
        expect(subject.send(:valid_submit_date)).to eq(["Submit date can't be blank"])
      end
    end
  end
  
  describe "#valid_updated_submit_date" do
    context "with a date input" do
      it "is expected to validate that :submit_date is valid when update" do
        subject.submit_date = "2020-06-14 03:27:00.0"
        expect(subject.send(:valid_updated_submit_date)).to eq(["Submit date must be greated that created date"])
      end
    end
    
    context "with blank" do
      it "is expected to validate that :submit_date can't blank when update" do
        subject.submit_date = ""
        expect(subject.send(:valid_updated_submit_date)).to eq(["Submit date can't be blank"])
      end
    end
  end

  # Class Method Test
  describe "#filter_by_priority" do
    context "with no priority & user type admin" do
      it "is expected to display all task" do
        expect(Task.filter_by_priority("", user1)).to include(task6, task5, task4, task3, task2, task1)
      end
    end
    
    context "when Medium priority & user type admin" do
      it "is expected to display medium priority task" do
        expect(Task.filter_by_priority("Medium", user1)).to include(task1, task4)
      end
    
      it "is expected not to display non Medium priority task" do
        expect(Task.filter_by_priority("Medium", user1)).to_not include(task6, task5, task3, task2)
      end
    end
    
    context "with Low priority & user type admin" do
      it "is expected to display display Low priority task" do
        expect(Task.filter_by_priority("Low", user1)).to include(task6, task3)
      end

      it "is expected not to display Low priority task" do
        task1.priority = "Low"
        expect(Task.filter_by_priority("Low", user1)).to_not include(task5, task4, task2, task1)
      end
    end
    
    context "with High priority task & user type admin" do
      it "is expected to display High priority" do
        expect(Task.filter_by_priority("High", user1)).to include(task5, task2)
      end

      it "is expected not display non High priority" do
        expect(Task.filter_by_priority("High", user1)).to_not include(task6, task4, task3, task1)
      end
    end
    
    context "with no priority & user type employee" do
      it "is expected to display My task" do
        expect(Task.filter_by_priority("", user2)).to include(task1, task2, task3)
      end

      it "is expected not to display others task" do
        expect(Task.filter_by_priority("", user2)).to_not include(task4, task5, task6)
      end
    end
    
    context "with Medium priority & user type Employee" do
      it "is expected to display Medium priority task" do
        expect(Task.filter_by_priority("Medium", user2)).to include( task1)
      end

      it "is expected to display Medium priority task" do
        expect(Task.filter_by_priority("Medium", user4)).to include( task4)
      end

      it "is expected not display others Medium" do
        expect(Task.filter_by_priority("Medium", user2)).to_not include(task4)
      end

      it "is expected not display others Medium" do
        expect(Task.filter_by_priority("Medium", user4)).to_not include(task1)
      end
    end
    
    context "with low priority & user type Employee" do
      it "is expected to display Low priority task" do
        expect(Task.filter_by_priority("Low", user2)).to include( task3)
      end

      it "is expected not to display others non Low priority task" do
        expect(Task.filter_by_priority("Low", user2)).to_not include(task6)
      end
    end
    
    context "with High priority & user type Employee" do
      it "is expected to display High priority task" do
        expect(Task.filter_by_priority("High", user2)).to include(task2)
      end

      it "is expected not to display others non High priority task" do
        expect(Task.filter_by_priority("High", user2)).to_not include(task5)
      end
    end
  end

  describe "#filter_approved_task_by_priority" do
    context "with no priority & user type admin" do
      it "includes all approved tasks" do
        expect(Task.filter_approved_task_by_priority("", user1)).to include(task1, task3, task4, task6)
      end
    end
    
    context "with no priority & user type HR" do
      it "includes all notified tasks" do
        expect(Task.filter_approved_task_by_priority("", user5)).to include(task3, task6)
      end
    end
    
    context "with Low priority & user type Admin" do
      it "includes low priority approved tasks" do
        expect(Task.filter_approved_task_by_priority("Low", user1)).to include(task3, task6)
      end
    end
    
    context "with Low priority & user type HR" do
      it "includes low priority notified tasks" do
        expect(Task.filter_approved_task_by_priority("Low", user5)).to include(task3, task6)
      end
    end
    
    context "with Medium priority & user type Admin" do
      it "includes Medium priority approved tasks" do
        expect(Task.filter_approved_task_by_priority("Medium", user1)).to include(task1, task4)
      end
    end
    
    context "with Medium priority & user type HR" do
      it "includes mediun priority notified tasks" do
        expect(Task.filter_approved_task_by_priority("Medium", user5)).to_not include(task1, task3)
      end
    end
    
    context "with High priority & user type Admin" do
      it "includes high priority approved tasks" do
        expect(Task.filter_approved_task_by_priority("High", user1)).to_not include(task1, task3, task4, task6)
      end
    end
    
    context "with High priority & user type HR" do
      it "includes High priority notified tasks" do
        expect(Task.filter_approved_task_by_priority("High", user5)).to_not include(task3, task6)
      end
    end
  end

  describe "#filter_user_assigned_task_by_priority" do
    context "with no priority" do
      it "is expected to include All user assigned task" do
        expect(Task.filter_user_assigned_task_by_priority("", user2)).to include(task4, task5, task6)
      end
    
      it "is expected to exclude others assigned task" do
        expect(Task.filter_user_assigned_task_by_priority("", user2)).to_not include(subject, task1, task2, task3)
      end
    end
    
    context "with Medium priority" do
      it "is expected to display Medium priority tasks" do
        expect(Task.filter_user_assigned_task_by_priority("Medium", user2)).to include(task4)
      end
    
      it "is expected not to display others medium priority task" do
        expect(Task.filter_user_assigned_task_by_priority("Medium", user2)).to_not include(task1)
      end
    end

    context "with Low Priority" do
      it "is expect to display Low priority task" do
        expect(Task.filter_user_assigned_task_by_priority("Low", user3)).to include(task3)
      end

      it "expecte not to display others lo priority task" do
        expect(Task.filter_user_assigned_task_by_priority("Low", user3)).to_not include(task6)
      end
    end
    
    context "with High Priority" do
      it "is expected to display High priority task" do
        expect(Task.filter_user_assigned_task_by_priority("High", user2)).to include(task5)
      end

      it "is expected not to display others High priority task" do
        expect(Task.filter_user_assigned_task_by_priority("High", user2)).to_not include(task2)
      end
    end
  end
end