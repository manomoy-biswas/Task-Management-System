require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let (:user1) {create(:employee)}
  
  describe "#welcome_user_email" do
    context "Is valid email data?" do
      let (:mail) { UserMailer.welcome_user_email(user1.id) }
      it "is expected to return valid subject" do
        expect(mail.subject).to eq("Welcome To Task Management System")
      end
      it "is expected to return valid receiver email" do
        expect(mail.to).to eq([user1.email])
      end
      it "is expected to return valid sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns valid @greeting" do
        expect(mail.body.encoded).to match("Hi #{user1.name}")
      end
      it "is expected to assigns valid @url" do
        expect(mail.body.encoded).to match("http://localhost:3000")
      end
      it "is expected to assigns valid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = UserMailer.welcome_user_email(user1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com")
      end
    end

    context "Is invalid email data?" do
      let (:mail) { UserMailer.welcome_user_email(user1.id) }
      it "is expected not to return invalid subject" do
        expect(mail.subject).to_not eq("Welcome To")
      end
      it "is expected not to return invalid receiver email" do
        expect(mail.to).to_not eq(nil)
      end
      it "is expected not to return invalid sender email/name" do
        expect(mail.from).to_not eq("TMS")
      end
      it "is expected to assigns invalid @greeting" do
        expect(mail.body.encoded).to_not match("Hi Admin")
      end
      it "is expected to assigns invalid @url" do
        expect(mail.body.encoded).to_not match("http://tms-kreeti.herokuapp.com")
      end
      it "is expected to assigns invalid @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = UserMailer.welcome_user_email(user1.id)
        expect(mail.body.encoded).to_not match("http://localhost:3000")
      end
    end
  end
end
