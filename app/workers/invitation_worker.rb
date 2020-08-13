class InvitationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(invite_id)
    InvitationMailer.send_invitation(invite_id).deliver
  end
end
