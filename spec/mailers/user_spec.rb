require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let (:user1) {create(:employee)}
  
  context "Mailer Method test" do
    describe "#welcome_user_email" do
      let (:mail) { UserMailer.welcome_user_email(user1.id) }
      it "is expected to render the subject" do
        expect(mail.subject).to eq("Welcome To Task Management System")
      end
      it "is expected to render the receiver email" do
        expect(mail.to).to eq([user1.email])
      end
      it "is expected to render the sender email/name" do
        expect(mail.from).to eq("Task Management System")
      end
      it "is expected to assigns @greeting" do
        expect(mail.body.encoded).to match("Hi #{user1.name}")
      end
      it "is expected to assigns @url" do
        expect(mail.body.encoded).to match("http://localhost:3000")
      end
      it "is expected to assigns @url for production" do
        allow(Rails).to receive(:env) { "production".inquiry }
       mail = UserMailer.welcome_user_email(user1.id)
        expect(mail.body.encoded).to match("http://tms-kreeti.herokuapp.com")
      end
    end
  end
end
