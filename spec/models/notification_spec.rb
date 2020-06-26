require "rails_helper"

RSpec.describe Notification, type: :model do
  
  let (:user1) { create(:admin) } 
  let (:user2) { create(:employee) }
  let (:user3) { create(:employee) }
  let (:category1) { create(:category) }
  let (:task) {create(:approved_task, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, approved_by: user1.id, notify_hr: true) }
  let (:notification1) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id) }
  let (:notification2) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id, read_at:"2020-05-09 18:32:38.0") }

  context "Association tests: " do
    it { is_expected.to belong_to(:task).with_foreign_key("notifiable_id")}
    it { is_expected.to belong_to(:user).with_foreign_key("user_id")}
    it { is_expected.to belong_to(:recipient).class_name("User").with_foreign_key("recipient_id")}
  end

  describe ".unread" do
    context "for unread notiofication" do
      it "includes notification with unread flag" do
        expect(Notification.unread(user2.id)).to include(notification1)
      end
    end
    context "for read notiofication" do
      it "includes notification with unread flag" do
        expect(Notification.unread(user2.id)).to_not include(notification2)
      end
    end
  end 

  describe ".all_notification" do
    context "for all notification" do
      it "includes all notification" do
        expect(Notification.all_notification(user2.id)).to include(notification1, notification2)
      end
    end
  end

  describe "#create_notification" do
    context "when notification created" do
      it "is expected to create task approved notification" do
        expect{ Notification.create_notification(task.id, "approved")}.to change{Notification.count}.by(2)
      end
      it "is expected to create task approved by notification" do
        expect{ Notification.create_notification(task.id, "approved by")}.to change{Notification.count}.by(2)
      end
      it "is expected to create task notified notification" do
        user4 = create(:hr)
        expect{ Notification.create_notification(task.id, "notified", user1.id)}.to change{Notification.count}.by(2)
      end
      it "is expected to create task submitted notification" do
        expect{ Notification.create_notification(task.id, "submitted")}.to change{Notification.count}.by(3)
      end
      it "is expected to create task assigned notification" do
        expect{ Notification.create_notification(task.id, "assigned")}.to change{Notification.count}.by(2)
      end
    end
  end
end