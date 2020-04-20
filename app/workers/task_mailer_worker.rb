class TaskMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  sidekiq_options queue: "mailer"

  def perform(task, method)
    case method
    when "create"
      TaskMailer.task_create_email(task).deliver
    when "update"
      TaskMailer.task_update_email(task).deliver
    when "approved"
      TaskMailer.task_approved_email(task).deliver
    when "approved by"
      TaskMailer.task_approval_email_to_admin(task).deliver
    else
      TaskMailer.task_reminder_email(task).deliver
    end
  end
end
