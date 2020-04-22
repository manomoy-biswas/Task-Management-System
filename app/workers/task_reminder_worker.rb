class TaskReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  # sidekiq_options queue: "default"
  def perform(task)
    unless task.submit
      TaskMailer.task_reminder_email(task).deliver
    end
  end
end
