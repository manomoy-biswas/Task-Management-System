require "sidekiq-scheduler"

class RecurringWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    today = DateTime.now
    recurring_tasks = Task.recurring_task
    recurring_tasks.each do |task|
      deadline = task.submit_date.to_datetime
      if today <= deadline
        unless task.submit
          case task.repeat
          when "Daily"
            Notification.create_notification(task.id, "Daily")
            
          when "Weekly"
            if today.wday == 1
              Notification.create_notification(task.id, "Weekly")
              TaskMailer.reminder_email(task.id, "Weekly").deliver
            end

          when "Monthly"
            if today.mday == 1
              Notification.create_notification(task.id, "Monthly")
              TaskMailer.reminder_email(task.id,"Monthly").deliver

            end

          when "Quarterly"
            if (today.mon == 1 || today.mon == 3 || today.mon == 6 || today.mon == 9) && today.mday ==1
              Notification.create_notification(task.id, "Quarterly")
              TaskMailer.reminder_email(task.id,"Quarterly").deliver
            end

          when "Half-yearly"
            if (today.mon == 1 || today.mon == 6) && today.mday ==1
              Notification.create_notification(task.id, "Half-yearly")
              TaskMailer.reminder_email(task.id, "half-yearly").deliver

            end

          when "Yearly"
            if today.yday == 1
              Notification.create_notification(task.id, "Yearly")
              TaskMailer.reminder_email(task.id, "yearly").deliver
            end
          else
          #nothing
          end
        end
      end
    end
  end
end
