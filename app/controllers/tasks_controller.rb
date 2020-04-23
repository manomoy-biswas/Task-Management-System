require "zip"
class TasksController < ApplicationController
  include TasksHelper
  include NotificationsHelper
  before_action :authenticate_user!
  before_action :check_user_is_hr?, except: [:index, :show, :approved_task]
  before_action :category_list, :employee_list, only: [:new, :create, :edit, :update]
  before_action :set_task, except: [:elastic_search,:assigned_by_me, :approved_task, :index, :submit_subtask, :create, :new]
  before_action :index, :assigned_by_me, :approved_task
  before_action :beautify_search_url, only: [:search]

  def index
    @tasks =  if admin? || hr?
                if !params[:priority] || params[:priority] == ""
                  Task.all.order("created_at DESC")
                else
                  Task.where(priority: params[:priority]).all.order("created_at DESC")
                end
              else
                if !params[:priority] || params[:priority] == ""
                  current_user.tasks
                else
                  current_user.tasks.where(priority: params[:priority]).all.order("created_at DESC")
                end
              end
  end
            
  def elastic_search
    if params[:q].blank?
      flash[:danger] = "Please enter a search term"
      redirect_to tasks_path
      return
    end
    if admin? || hr?
      @tasks = Task.search(params[:q].present? ? params[:q] : nil)
    else
      @tasks = Task.search((params[:q].present? ? params[:q] : nil), current_user.id)
    end
  end

  def notify_hr
    return unless admin?

    return unless @task.approved

    @task.notify_hr = true
    @task.save
    flash[:success] = "A notification has been sent to all HRS"
    create_notification(@task.id, "notified")
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
      flash[:warning] = I18n.t "task.submit_task.failed"
      redirect_to request.referrer
      return
    end
    @task.submit = true
    @task.save
    flash[:success] = I18n.t "task.submit_task.success"
    redirect_to request.referrer
  end

  def submit_subtask
    @subtask = SubTask.find(params[:id])
    @subtask.submit = true
    @subtask.save
    flash[:success] = I18n.t "task.submit_subtask.success", subtask: @subtask.name
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
          TaskMailerWorker.perform_async(@task.id,"approved by")
        end
        flash[:success] = I18n.t "task.approve.success"
        redirect_to request.referrer
      end
    end
  end

  def download
    filename = @task.task_name + "_" + DateTime.parse(@task.created_at.to_s).strftime("%d-%m-%Y") +".zip"
    temp_file = Tempfile.new(filename)
    begin
      Zip::OutputStream.open(temp_file) { |zos| }
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        @task.task_document.each do |file|
          zip.add(file.document.file.filename, file.document.path.to_s)
        end
      end
      read_data = File.read(temp_file.path)
      send_data(read_data, type: "application/zip", filename: filename)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.assign_task_by = current_user.id
    @task.submit_date = task_params[:submit_date].to_datetime
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true
    end
    if @task.save
      if params[:task_document].present?
        params[:task_document]["document"].each do |file|
          @task_document = @task.task_document.create(document: file, task_id: @task.id)
        end
      end
      Notification.create_notification(@task.id, "assigned")
      flash[:success]= I18n.t "task.success", task_name: @task.task_name, task_id: @task.id
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t "task.failed"
      render "new"
    end
  end


  def edit
  end

  def update
    if task_params[:repeat] == "One Time"
      @task.recurring_task = false
    else
      @task.recurring_task = true unless @task.submit
    end
    @task.submit_date = task_params[:submit_date].to_datetime

    if @task.update(task_params)
      if params[:task_document].present?
        params[:task_document]["document"].each do |file|
          @task_document = @task.task_document.create(document: file, task_id: @task.id)
        end
      end
      Notification.create_notification(@task.id, "updated")
      flash[:success] = I18n.t "task.update_success", task_name: @task.task_name
      redirect_to task_path(@task)
    else
      flash[:danger] = I18n.t "task.failed"
      render "edit"
    end
  end

  def show
  end

  def destroy
    if @task.present?
      taskname= " id: " + @task.id.to_s + " " + @task.task_name
      @task.destroy
      flash[:success] = I18n.t "task.destroy", task: taskname
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t "task.not_exist"
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
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy), task_document_attributes: [:id, :task_id, :document])
  end

  def beautify_search_url   
    redirect_to search_tasks_path(query: params[:query]) if params[:query].present?
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
