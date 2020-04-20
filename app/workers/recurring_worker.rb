class RecurringWorker
  require "sidekiq-scheduler"
  include Sidekiq::Worker
  include NotificationsHelper
  sidekiq_options retry: false

  def perform
    current_date = DateTime.now
    task_list = Task.where(recurring_task: 1)
    task_list.each do |task|
      task_date = task.submit_date.to_datetime
      if current_date <= task_date
        return if task.submit

        case task.repeat
          when "Daily"
            create_notification(task.id, "Daily")

          when "Weekly"
            if current_date.wday == 1
              create_notification(task.id, "Weekly")
              TaskMailer.delay.reminder_email(task, "Weekly")
            end

          when "Monthly"
            if current_date.day == 1
              create_notification(task.id, "Monthly")
              TaskMailer.reminder_email(task,"Monthly").deliver

            end

          when "Quarterly"
            if [1,91,182,274].include?(current_date.yday)
              create_notification(task.id, "Quarterly")
              TaskMailer.reminder_email(task,"Quarterly").deliver
            end

          when "Half-yearly"
            if [1,182].include?(current_date.yday)
              create_notification(task.id, "Half-yearly")
              TaskMailer.reminder_email(task, "half-yearly").deliver

            end

          when "Yearly"
            if current_date.yday == 1
              create_notification(task.id, "Yearly")
              TaskMailer.reminder_email(task, "yearly").deliver
            end
        else
          #nothing
        end
      end
    end
  end
end
