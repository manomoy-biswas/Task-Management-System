class TaskReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  def perform(task_id)
    task=Task.find(task_id)
    unless task.submit
      TaskMailer.task_reminder_email(task.id).deliver
    end
  end
end
