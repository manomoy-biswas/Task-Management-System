class ResetPasswordWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id)
    UserMailer.password_reset(user_id).deliver
  end
end
