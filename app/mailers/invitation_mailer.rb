class InvitationMailer < ApplicationMailer
  default from: 'Task Management System'
  
  def send_invitation(invite_id)
    @invite = Invitation.find(invite_id)
    @greeting = "Hi #{@invite.name}"
    mail to: @invite.email, subject: "Invitation from Task Management System"
  end
end
