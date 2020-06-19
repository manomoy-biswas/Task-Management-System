require "rails_helper"

RSpec.describe Notification, type: :model do

  context "Association tests: " do
    it { is_expected.to belong_to(:task).with_foreign_key("notifiable_id")}
    it { is_expected.to belong_to(:user).with_foreign_key("user_id")}
    it { is_expected.to belong_to(:recipient).class_name("User").with_foreign_key("recipient_id")}
  end

  context "Scope tests:" do
    let (:user1) { create(:admin) } 
    let (:user2) { create(:employee) }
    let (:user3) { create(:employee) }
    let (:category1) { create(:category) }
    let (:category2) { create(:category) }
    let (:task1) {create(:assigned_task1, task_category: category2.id, assign_task_to: user2.id, assign_task_by: user3.id)}
    let (:task2) {create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user1.id)}
    let (:notification1) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id) }
    let (:notification2) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, read_at:"2020-05-09 18:32:38.0") }
    describe ".unread" do
      it "includes notification with unread flag" do
        expect(Notification.unread(user2.id)).to include(notification1)
      end
    end
    describe ".all_notification" do
      it "includes all notification" do
        expect(Notification.all_notification(user2.id)).to include(notification1, notification2)
      end
    end
  end

  context "Method test" do
    describe "#create_notification" do
      it "is expected to create task approved notification" do
        user1 = create(:admin)
        user2 = create(:employee)
        user3 = create(:employee)
        category = create(:category)
        task = create(:assigned_task1, task_category: category.id, assign_task_to: user2.id, assign_task_by: user3.id, submit: true, approved: true, approved_by: user3.id)
        expect{ Notification.create_notification(task.id, "approved")
        }.to change{Notification.count}.by(1)
      end
      
      it "is expected to create task approved by notification" do
        user1 = create(:admin)
        user2 = create(:employee)
        user3 = create(:employee)
        category = create(:category)
        task = create(:assigned_task1, task_category: category.id, assign_task_to: user2.id, assign_task_by: user3.id, submit: true, approved: true, approved_by: user1.id)
        expect{ Notification.create_notification(task.id, "approved by")}.to change{Notification.count}.by(2)
      end
      
      it "is expected to create task notified notification" do
        user1 = create(:admin)
        user2 = create(:employee)
        user3 = create(:employee)
        user4 = create(:hr)
        category = create(:category)
        task = create(:assigned_task1, task_category: category.id, assign_task_to: user2.id, assign_task_by: user3.id, submit: true, approved: true, approved_by: user1.id, notify_hr: true)
        expect{ Notification.create_notification(task.id, "notified", user1.id)
        }.to change{Notification.count}.by(1)
      end

      it "is expected to create task submitted notification" do
        user1 = create(:admin)
        user2 = create(:employee)
        user3 = create(:employee)
        category = create(:category)
        task = create(:assigned_task1, task_category: category.id, assign_task_to: user2.id, assign_task_by: user3.id, submit: true)
        expect{ Notification.create_notification(task.id, "submitted")
        }.to change{Notification.count}.by(3)
      end
      
      it "is expected to create task assigned notification" do
        user1 = create(:admin)
        user2 = create(:employee)
        user3 = create(:employee)
        category = create(:category)
        task = create(:assigned_task1, task_category: category.id, assign_task_to: user2.id, assign_task_by: user3.id)
        expect{ Notification.create_notification(task.id, "assigned")
        }.to change{Notification.count}.by(1)
      end
    end
  end
end