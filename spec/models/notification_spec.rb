require "rails_helper"

RSpec.describe Notification, type: :model do

  it "should belong_to task" do
    expect(Notification.reflect_on_association(:task).macro).to eq :belongs_to
  end

  it "should belong_to user" do
    expect(Notification.reflect_on_association(:user).macro).to eq :belongs_to
  end

  it "should belong_to recipient" do
    expect(Notification.reflect_on_association(:recipient).macro).to eq :belongs_to
  end
  # describe ".unread" do
  #   before {User.new(id: 1, name: "Arnab Roy", email: "arnab.roy@kreet.com", phone: "7894561230", dob: "01-01-1996").save(validate: false)}
  #   before {User.new(id: 4, name: "Arnab Roy", email: "arnab.roy@gmail.com", phone: "7894561231", dob: "01-01-1996").save(validate: false)}
  #   before {Task.create(
  #     id: 1,
  #     task_category: 1,
  #     task_name: Faker::Lorem.sentence,
  #     assign_task_to: [2, 4].sample,
  #     assign_task_by: [1, 3].sample,
  #     priority: ["Low", "Medium", "High"].sample,
  #     repeat: "One_Time",
  #     submit_date: Faker::Date.between(1.days.from_now, 2.years.from_now),
  #     recurring_task: false,
  #     description: Faker::Lorem.paragraph(rand(30..40))
  #   )}
    it "includes notification with unread flag" do
      unread = Notification.create(recipient_id: 4, user_id: 1, action: "approved", notifiable_type: "Task", notifiable_id:1)
      expect(Notification.unread(4)).to include(unread)
    end
  # end
end