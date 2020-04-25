class TaskReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  # sidekiq_options queue: "default"
  def perform(task_id)
    task=Task.find(task_id)
    unless task.submit
      TaskMailer.task_reminder_email(task).deliver
    end
  end
end
