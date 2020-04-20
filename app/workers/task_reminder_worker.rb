class TaskReminderWorker
  include Sidekiq::Worker

  def perform(task)
    unless task.submit
      TaskMailer.task_reminder_email(task).deliver
    end
  end
end
