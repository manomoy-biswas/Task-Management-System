class TaskMailer < ApplicationMailer
  default from: 'Task Management System'

  def task_create_email(task_id)
    @task = Task.find(task_id)
    @greeting = "Hi #{User.find(@task.assign_task_to).name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: User.find(@task.assign_task_to).email, subject: "Task Assigned: #{@task.task_name}"
  end

  def task_update_email(task_id)
    @task = Task.find(task_id)
    @greeting = "Hi #{@task.user.name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: User.find(@task.assign_task_to).email, subject: "Task Updated: #{@task.task_name}"
  end

  def reminder_email(task_id,type)
    @task = Task.find(task_id)
    @greeting = "Hi #{User.find(@task.assign_task_to).name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: User.find(@task.assign_task_to).email, subject: "#{type} Reminder: #{@task.task_name}"
  end

  def task_reminder_email(task_id)
    @task = Task.find(task_id)
    @greeting = "Hi #{User.find(@task.assign_task_to).name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: User.find(@task.assign_task_to).email, subject: "Task Reminder: #{@task.task_name}"
  end

  def task_approval_email_to_admin(task_id)
    @task = Task.find(task_id)
    @greeting = 'Hi Admin,'
    @assign_task_by = User.find(@task.assign_task_by).name
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: 'manomoy26@gmail.com', subject: "Task Approved: #{@task.task_name}"
  end

  def task_approved_email(task_id)
    @task = Task.find(task_id)
    @greeting = "Hi #{User.find(@task.assign_task_to).name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: User.find(@task.assign_task_to).email, subject: "Task Approved: #{@task.task_name}"
  end

  def notified_task_email(user_id, task_id)
    @task = Task.find(task_id)
    @greeting = "Hi #{User.find(user_id).name},"
    if Rails.env.development? || Rails.env.test?
      @url ="http://localhost:3000/tasks/" + @task.id.to_s 
    else
      @url ="http://tms-kreeti.herokuapp.com/tasks/" + @task.id.to_s 
    end

    mail to: User.find(user_id).email, subject: "Task Approved Notification: #{@task.task_name}"
  end
end
