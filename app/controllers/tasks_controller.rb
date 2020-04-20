class TasksController < ApplicationController
  include TasksHelper
  include NotificationsHelper
  before_action :authenticate_user!
  before_action :check_user_is_hr?, except: [:index, :show, :approved_task]
  before_action :category_list, :employee_list, only: [:new, :create, :edit, :update]
  before_action :set_task, except: [:assigned_by_me, :approved_task, :index, :submit_subtask, :create, :new]
  before_action :index, :assigned_by_me, :approved_task

  def index
    if params[:priority] != ""
      if admin? || hr?
        @tasks =  Task.where(priority: params[:priority]).all.order("created_at DESC")
      else
        @tasks =  current_user.tasks.where(priority: params[:priority]).all.order("created_at DESC")
      end
    else
      @tasks = Task.all.order("created_at DESC")
    end
  end

  def notify_hr
    return unless admin?

    return unless @task.approved

    @task.notify_hr = true
    @task.save
    flash[:success] = 'A notification has been sent to all HRS'
    create_notification(@task.id, 'notified')
    redirect_to request.referrer
  end

  def approved_task
    @tasks_approved = Task.where(approved: 1)
  end

  def assigned_by_me
    @tasks_assigned_by = Task.where(assign_task_by: current_user)
  end

  def submit_task
    unless SubTask.all_subtasks_submitted(@task)
      flash[:warning] = I18n.t 'task.submit_task.failed'
      redirect_to request.referrer
      return
    end
    @task.submit = true
    @task.save
    flash[:success] = I18n.t 'task.submit_task.success'
    redirect_to request.referrer
  end

  def submit_subtask
    @subtask = SubTask.find(params[:id])
    @subtask.submit = true
    @subtask.save
    flash[:success] = I18n.t 'task.submit_subtask.success', subtask: @subtask.name
    redirect_to task_path(@subtask.task_id)
  end

  def approve
    unless @task.submit
      flash[:warning] = "Employee not Submitted the task yet."
      redirect_to request.referrer
      return
    end
    if @task.approved
      flash[:success] = "already Approved"
      redirect_to request.referrer
    else
      @task.approved = true
      @task.approved_by = current_user.id
      if @task.save(validate: false)
        Notification.create_notification(@task.id, "approved")
        TaskMailerWorker.perform_async(@task.id,"approved")
        unless admin?
          Notification.create_notification(@task.id, "approved by")
          TaskMailerWorker.perform_asycn(@task.id,"approved by")
        end
        flash[:success] = I18n.t 'task.approve.success'
        redirect_to request.referrer
      end
    end
  end

  def download
    send_file ("#{Rails.root}/public#{@task.document.url.rpartition("?").first}"),
    filename: @task.document_file_name,
    type: @task.document_content_type,
    disposition: 'attachment'
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.assign_task_by = current_user.id
    @task.submit_date = task_params[:submit_date].to_datetime
    unless task_params[:repeat] == 'One Time'
      @task.recurring_task = true
    end
    if @task.save
      Notification.create_notification(@task.id, 'assigned')
      flash[:success]= I18n.t 'task.success', task_name: @task.task_name, task_id: @task.id
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t 'task.failed'
      render 'new'
    end
  end


  def edit
  end

  def update
    if task_params[:repeat] == 'One Time'
      @task.recurring_task = false
    else
      @task.recurring_task = true unless @task.submit
    end
    @task.submit_date = task_params[:submit_date].to_datetime

    if @task.update(task_params)
      Notification.create_notification(@task.id, 'updated')
      flash[:success] = I18n.t 'task.update_success', task_name: @task.task_name
      redirect_to task_path(@task)
    else
      flash[:danger] = I18n.t 'task.failed'
      render 'edit'
    end
  end

  def show
  end

  def destroy
    if @task.present?
      taskname= ' id: ' + @task.id.to_s + ' ' + @task.task_name
      @task.destroy
      flash[:success] = I18n.t 'task.destroy', task: taskname
      redirect_to tasks_path
    else
      flash[:danger] = "Task doesn't exists"
    end
  end

  private
  def category_list
    @categories ||= Category.all
  end

  def employee_list
    @users ||= User.all_except(current_user)
  end

  def task_params
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat, :document,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy))
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
