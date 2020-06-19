class UserMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user)
    UserMailer.welcome_user_email(user).deliver
  end
end