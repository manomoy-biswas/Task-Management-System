require 'rails_helper'

RSpec.describe NotificationRelayWorker, type: :worker do
  let (:user1) { create(:admin) } 
    let (:user2) { create(:employee) }
    let (:user3) { create(:employee) }
    let (:category1) { create(:category) }
    let (:task1) {create(:assigned_task1, task_category: category1.id, assign_task_to: user2.id, assign_task_by: user3.id)}
    let (:task2) {create(:assigned_task1, task_category: category1.id, assign_task_to: user3.id, assign_task_by: user2.id)}
    let (:notification2) { create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, read_at:"2020-05-09 18:32:38.0") }
  describe "#perform" do
    context "for approved task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id)
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end

    context "for assigned task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "assigned")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end

    context "for approved by task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "approved by")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for notified task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "notified")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for submitted task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "submitted")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for submitted task" do
      it "is expected to send a notification" do
        u1 = create(:employee) 
        u2 = create(:employee) 
        u3 = create(:admin) 

        c1=create(:category) 
        t1=create(:assigned_task1, task_category: c1.id, assign_task_to: u2.id, assign_task_by: u1.id, submit: true)
        n1 = create(:notification, recipient_id: u1.id, user_id: u2.id, notifiable_id: t1.id, action: "submitted")
        expect { NotificationRelayWorker.new.perform(n1.id) }.to have_broadcasted_to("notifications_channel_#{n1.recipient_id}")
      end
    end

    context "for daily task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "Daily")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for weekly task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "Weekly")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for monthly task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "Monthly")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for Quarterly task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "Quarterly")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for Half_Yearly task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "Half_Yearly")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for Yearly task" do
      it "is expected to send a notification" do
        notification1 = create(:notification, recipient_id: user2.id, user_id: user1.id, notifiable_id:task1.id, action: "Yearly")
        expect { NotificationRelayWorker.new.perform(notification1.id) }.to have_broadcasted_to("notifications_channel_#{notification1.recipient_id}")
      end
    end
    
    context "for read task" do
      it "is expected to return nil" do
        expect(NotificationRelayWorker.new.perform(notification2.id)).to eq(nil)
      end
    end
  end
end