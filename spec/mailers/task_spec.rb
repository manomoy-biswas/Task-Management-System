require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  let (:user1) {create(:admin)}
  let (:user2) {create(:employee)}
  let (:user3) {create(:employee)}
  let (:user4) {create(:hr)}
  let (:category1) {create(:category)}
  let (:task1) { create(:assigned_task2, task_category: category1.id, assign_task_to: user2.id, priority: "Medium", assign_task_by: user1.id, approved: true)}
  let (:task2) { create(:assigned_task1, task_category: category1.id, assign_task_to: user3.id, assign_task_by: user2.id, priority: "High", approved_by: user2.id, approved: true, notify_hr: true)}
  
  describe "#task_create_email" do
    let (:mail) { TaskMailer.task_create_email(task1.id) }
    context "with valid email data" do
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Task Assigned: #{task1.task_name}")
      end

      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user2.email])
      end

      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end

      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user2.name}")
      end
  
      it "is expected to assigns valid @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end

      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end

      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_create_email(task1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end

    context "With invalid email data" do
      it "is expected  not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Assigned: #{task2.task_name}")
      end

      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user3.email])
      end

      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end

      it "is expected not to return invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user3.name}")
      end
  
      it "is expected not to assigns invalid @assign_task_by" do
        expect(mail.body.encoded).to_not match(user3.name)
      end

      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end

      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_create_email(task1.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
    end
  end

  describe "#task_update_email" do
    let (:mail) { TaskMailer.task_update_email(task1.id) }
    context "with valid email data" do
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Task Updated: #{task1.task_name}")
      end

      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user2.email])
      end

      it "is expected to rereturn valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end

      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user2.name}")
      end

      it "is expected to assigns valid @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_update_email(task1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end
    context "with invalid email data" do
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Updated: #{task2.task_name}")
      end
      
      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user3.email])
      end
      
      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end
      
      it "is expected not to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user1.name}")
      end

      it "is expected not to assigns invalid @assign_task_by" do
        expect(mail.body.encoded).to_not match(user3.name)
      end
      
      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
      
      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_update_email(task1.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
    end
  end

  describe "#reminder_email" do
    let (:mail) { TaskMailer.reminder_email(task1.id, "Weekly") }
    context "with valid email data" do 
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Weekly Reminder: #{task1.task_name}")
      end
      
      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user2.email])
      end
      
      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      
      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user2.name}")
      end

      it "is expected to assigns valid @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.reminder_email(task1.id, "Weekly")
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end
    context "with invalid email data" do
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Updated: #{task2.task_name}")
      end
      
      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user3.email])
      end
      
      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end
      
      it "is expected not to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user1.name}")
      end

      it "is expected not to assigns invalid @assign_task_by" do
        expect(mail.body.encoded).to_not match(user3.name)
      end
      
      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
      
      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_update_email(task1.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
    end
  end
  
  describe "#task_reminder_email" do
    let (:mail) { TaskMailer.task_reminder_email(task1.id) }
    context "with valid email data" do
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Task Reminder: #{task1.task_name}")
      end
      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user2.email])
      end
      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user2.name}")
      end

      it "is expected to assigns valid @assign_task_by" do
        expect(mail.body.encoded).to match(user1.name)
      end
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_reminder_email(task1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
    end

    context "with invalid email data" do
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Updated: #{task2.task_name}")
      end
      
      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user3.email])
      end
      
      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end
      
      it "is expected not to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user1.name}")
      end

      it "is expected not to assigns invalid @assign_task_by" do
        expect(mail.body.encoded).to_not match(user3.name)
      end
      
      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task1.id.to_s)
      end
      
      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_update_email(task1.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task1.id.to_s)
      end
    end
  end

  describe "#task_approval_email_to_admin" do
    let (:mail) { TaskMailer.task_approval_email_to_admin(task2.id) }
    context "with valid email data" do
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Task Approved: #{task2.task_name}")
      end
      it "is expected to return valid receiver email" do
        expect(mail.to).to eq(["manomoy26@gmail.com"])
      end
      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi Admin,")
      end

      it "is expected to assigns valid @assign_task_by" do
        expect(mail.body.encoded).to match(user2.name)
      end
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_approval_email_to_admin(task2.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end
    end

    context "with invalid email data" do
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Approved: #{task1.task_name}")
      end

      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user2.email])
      end

      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end

      it "is expected not to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user1.name}")
      end

      it "is expected not to assigns invalid @assign_task_by" do
        expect(mail.body.encoded).to_not match(user1.name)
      end

      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end

      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_approved_email(task2.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
    end
  end
  
  describe "#task_approved_email" do
    let (:mail) { TaskMailer.task_approved_email(task2.id) }
    context "with valid email data" do
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Task Approved: #{task2.task_name}")
      end
      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user3.email])
      end
      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user3.name}")
      end

      it "is expected to assigns valid @assign_task_by" do
        expect(mail.body.encoded).to match(user2.name)
      end
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_approved_email(task2.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end
    end

    context "with invalid email data" do
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Approved: #{task1.task_name}")
      end

      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user2.email])
      end

      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end

      it "is expected not to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user1.name}")
      end

      it "is expected not to assigns invalid @assign_task_by" do
        expect(mail.body.encoded).to_not match(user1.name)
      end

      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end

      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.task_approved_email(task2.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
    end
  end

  describe "#notified_task_email" do
    let (:mail) { TaskMailer.notified_task_email(user4.id, task2.id) }
    context "with valid email data" do
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Task Approved Notification: #{task2.task_name}")
      end
      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user4.email])
      end
      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user4.name},")
      end
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.notified_task_email(user4.id, task2.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end
    end

    context "with invalid email data" do
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Task Approved: #{task1.task_name}")
      end

      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq([user2.email])
      end

      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end

      it "is expected not to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi #{user1.name},")
      end
      it "is expected not to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com/tasks/" + task2.id.to_s)
      end

      it "is expected not to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
        mail = TaskMailer.notified_task_email(user4.id, task2.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000/tasks/" + task2.id.to_s)
      end
    end
  end
end