require "rails_helper"

RSpec.describe Notification, type: :model do
  
  let (:user1) { create(:admin) } 
  let (:user2) { create(:employee) }
  let (:user3) { create(:employee) }
  let (:category1) { create(:category) }
  
  let (:task) {create(:approved_task, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id, approved_by: user1.id, notify_hr: true) }
  
  let (:notification1) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id, created_at: "#{Date.today}") }
  
  let (:notification2) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id, read_at: "#{Date.today}", created_at: "#{Date.yesterday}") }

  let (:notification3) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id, created_at: "#{Date.today.at_beginning_of_week - 3}") }

  let (:notification4) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id, created_at: "#{Date.today.at_beginning_of_month - 3}") }

  let (:notification5) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task.id, created_at: "#{Date.today.at_beginning_of_year - 3}") }

  describe "Model association test " do
    it { is_expected.to belong_to(:task).with_foreign_key("notifiable_id")}
    it { is_expected.to belong_to(:user).with_foreign_key("user_id")}
    it { is_expected.to belong_to(:recipient).class_name("User").with_foreign_key("recipient_id")}
  end

  describe ".unread" do
    context "with unread notiofication" do
      it "includes notification with unread flag" do
        expect(Notification.unread(user2.id)).to include(notification1, notification3, notification4, notification5)
      end
    end
    context "with read notiofication" do
      it "includes notification with unread flag" do
        expect(Notification.unread(user2.id)).to_not include(notification2)
      end
    end
  end 

  describe ".all_notification" do
    context "with all notification" do
      it "includes all notification" do
        expect(Notification.all_notification(user2.id)).to include(notification1,notification2, notification3, notification4, notification5)
      end
    end
  end

  describe ".todays_notifications" do
    context "with todays notification" do
      it "includes only todays notification" do
        expect(Notification.todays_notifications(user2.id)).to include(notification1)
      end
    end
  end

  describe ".yesterdays_notifications" do
    context "with yesterdays notification" do
      it "includes only yesterdays notification" do
        expect(Notification.yesterdays_notifications(user2.id)).to include(notification2)
      end
    end
  end

  describe ".weekly_notifications" do
    context "with this weeks notification" do
      it "includes only this weeks notification" do
        expect(Notification.weekly_notifications(Date.today, user2.id)).to include(notification1,notification2)
      end
    end
    context "with last weeks notification" do
      it "includes only last weeks notification" do
        expect(Notification.weekly_notifications(Date.today.at_beginning_of_week - 1, user2.id)).to include(notification3)
      end
    end
  end

  describe ".monthly_notifications" do
    context "with this months notification" do
      it "includes only this months notification" do
        expect(Notification.monthly_notifications(Date.today, user2.id)).to_not include(notification4, notification5)
      end
    end
    context "with last months notification" do
      it "includes only last months notification" do
        expect(Notification.monthly_notifications(Date.today.at_beginning_of_month - 1, user2.id)).to include(notification4)
      end
    end
  end

  describe ".yearly_notifications" do
    context "with this years notification" do
      it "includes only this years notification" do
        expect(Notification.yearly_notifications(Date.today, user2.id)).to_not include(notification5)
      end
    end
    context "with last years notification" do
      it "includes only last years notification" do
        expect(Notification.yearly_notifications(Date.today.at_beginning_of_year - 1, user2.id)).to include(notification5)
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

  describe "#fetch_notification" do
    context "with no filter option" do
      it "includes all notification" do
        expect(Notification.fetch_notification("", user2.id)).to include(notification1,notification2, notification3, notification4, notification5)
      end
    end

    context "with todays filter" do
      it "includes only todays notification" do
        expect(Notification.fetch_notification("today", user2.id)).to include(notification1)
      end
    end
  
    context "with yesterday filter" do
      it "includes only yesterdays notification" do
        expect(Notification.fetch_notification("yesterday", user2.id)).to include(notification2)
      end
    end
    
    context "with this weeks filter" do
      it "includes only this weeks notification" do
        expect(Notification.fetch_notification("this week", user2.id)).to include(notification1,notification2)
      end
    end

    context "with previous weeks filter" do
      it "includes only previous weeks notification" do
        expect(Notification.fetch_notification("previous week",  user2.id)).to include(notification3)
      end
    end
    
    context "with this months notification" do
      it "includes only this months notification" do
        expect(Notification.fetch_notification("this month",  user2.id)).to_not include(notification4, notification5)
      end
    end
    
    context "with last months notification" do
      it "includes only last months notification" do
        expect(Notification.fetch_notification("previous month", user2.id)).to include(notification4)
      end
    end

    context "with this years notification" do
      it "includes only this years notification" do
        expect(Notification.fetch_notification("this year", user2.id)).to_not include(notification5)
      end
    end
    context "with previous years notification" do
      it "includes only last years notification" do
        expect(Notification.fetch_notification("previous year", user2.id)).to include(notification5)
      end
    end
  end
end