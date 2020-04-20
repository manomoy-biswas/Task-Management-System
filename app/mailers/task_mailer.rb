class TaskMailer < ApplicationMailer
  default from: 'Task Management System'

  def task_create_email(task)
    @task = task
    @greeting = "Hi #{@task.user.name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @task.user.email, subject: "Task Assigned: #{@task.task_name}"
  end

  def task_update_email(task)
    @task = task
    @greeting = "Hi #{@task.user.name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @task.user.email, subject: "Task Updated: #{@task.task_name}"
  end

  def reminder_email(task,type)
    @task = task
    @greeting = "Hi #{@task.user.name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @task.user.email, subject: "#{type} Reminder: #{@task.task_name}"
  end

  def task_reminder_email(task)
    @task = task
    @greeting = "Hi #{@task.user.name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @task.user.email, subject: "Task Reminder: #{@task.task_name}"
  end

  def task_approval_email_to_admin(task)
    @task = task
    @greeting = 'Hi Admin,'
    @assign_task_by = User.find(@task.assign_task_by).name
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: 'manomoy26@gmail.com', subject: "Task Approved: #{@task.task_name}"
  end

  def task_approved_email(task)
    @task = task
    @greeting = "Hi #{@task.user.name},"
    @assign_task_by = User.find(@task.assign_task_by).name
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @task.user.email, subject: "Task Approved: #{@task.task_name}"
  end

  def task_destroy_email(task)
    @task = task
    @greeting = "Hi,"
    @assign_task_by = User.find(@task.assign_task_by)
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @task.user.email, subject: "Task Deleted: #{@task.task_name}"
  end

  def task_destroy_email_to_assignee(task)
    @task = task
    @assign_task_by = User.find(@task.assign_task_by)
    @greeting = "Hi #{@assign_task_by.name},"
    @url ="http://localhost:3000/tasks/"+@task.id.to_s

    mail to: @assign_task_by.email, subject: "Task Deleted: #{@task.task_name}"
  end
end
