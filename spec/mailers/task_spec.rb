require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:employee)}
  let (:category1) {create(:category)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, priority: "Medium", assign_task_by: user1.id, approved: true)}
  let (:task2) { create(:assigned_task1, task_category: category1.id, assign_task_to: user3.id, assign_task_by: user2.id, priority: "High", approved_by: user2.id)}
  
  context "Mailer Method test" do
    describe "#task_create_email" do
      let (:mail) { TaskMailer.task_create_email(task1.id) }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Task Assigned: #{task1.task_name}")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq([user2.email])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match(user2.name)
      end
  
      it "is expected to assigns @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = TaskMailer.task_create_email(task1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end

    describe "#task_update_email" do
      let (:mail) { TaskMailer.task_update_email(task1.id) }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Task Updated: #{task1.task_name}")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq([user2.email])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match(user2.name)
      end
  
      it "is expected to assigns @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = TaskMailer.task_update_email(task1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end

    describe "#reminder_email" do
      let (:mail) { TaskMailer.reminder_email(task1.id, "Weekly") }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Weekly Reminder: #{task1.task_name}")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq([user2.email])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match("Hi #{user2.name}")
      end
  
      it "is expected to assigns @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = TaskMailer.reminder_email(task1.id, "Weekly")
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end
    
    describe "#task_reminder_email" do
      let (:mail) { TaskMailer.task_reminder_email(task1.id) }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Task Reminder: #{task1.task_name}")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq([user2.email])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match("Hi #{user2.name}")
      end
  
      it "is expected to assigns @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = TaskMailer.task_reminder_email(task1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end

    describe "#task_approval_email_to_admin" do
      let (:mail) { TaskMailer.task_approval_email_to_admin(task2.id) }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Task Approved: #{task2.task_name}")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq(["manomoy26@gmail.com"])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match("Hi Admin,")
      end
  
      it "is expected to assigns @assign_task_by" do
        expect(mail.body.encoded).to match(user2.name)
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = TaskMailer.task_approval_email_to_admin(task2.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end
    end
    
    describe "#task_approved_email" do
      let (:mail) { TaskMailer.task_approved_email(task2.id) }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Task Approved: #{task2.task_name}")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq([user3.email])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match("Hi #{user3.name}")
      end
  
      it "is expected to assigns @assign_task_by" do
        expect(mail.body.encoded).to match(user2.name)
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = TaskMailer.task_approved_email(task2.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end
    end
  end
end