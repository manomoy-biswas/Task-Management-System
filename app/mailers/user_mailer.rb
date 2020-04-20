class UserMailer < ApplicationMailer
  default from: 'Task Management System'
  def welcome_user_email
    @user = params[:user]
    @greeting = "Hi"
    @url = "http://localhost:3000"

    mail to: @user.email, subject: "Welcome To Task Management System"
  end
end
