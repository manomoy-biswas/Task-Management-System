class TaskMailerJob < ApplicationJob
  queue_as :low_priority

  def perform(task, method)
    @task = task
    case method
      when "create"
        TaskMailer.delay.task_create_email(@task)
      when "update"
        TaskMailer.delay.task_update_email(@task)
      when "approved"
        TaskMailer.delay.task_approved_email(@task)
      when "approved by"
        TaskMailer.delay.task_approval_email_to_admin(@task)
      when "destroy"
        TaskMailer.delay.task_destroy_email(@task)
      when "destroy by"
        TaskMailer.delay.task_destroy_email_to_assignee(@task)
    else
      TaskMailer.delay.task_reminder_email(@task)
    end
  end
end
