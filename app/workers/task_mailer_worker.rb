class TaskMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(task_id, method, user_id=nil)
    case method
    when "create"
      TaskMailer.task_create_email(task_id).deliver
    when "update"
      TaskMailer.task_update_email(task_id).deliver
    when "approved"
      TaskMailer.task_approved_email(task_id).deliver
    when "approved by"
      TaskMailer.task_approval_email_to_admin(task_id).deliver
    when "notified"
      TaskMailer.notified_task_email(user_id, task_id).deliver
    else
      TaskMailer.task_reminder_email(task_id).deliver
    end
  end
end
