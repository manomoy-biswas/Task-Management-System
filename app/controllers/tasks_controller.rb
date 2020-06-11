class TasksController < ApplicationController
  require "zip"
  include TasksHelper
  
  before_action :authenticate_user!
  before_action :check_user_is_hr, except: [:approved_task, :print_task_list, 
                :print_task_details, :show]
  before_action :category_list, :employee_list, only: [:new, :create, :edit, :update]
  before_action :set_task, only: [:approve, :destroy, :download, :edit, :notify_hr, :show,
                :submit_task, :update]
  after_action :create_approved_notification_and_email, only: [:approve]
  after_action :create_update_notification_and_email, only: [:update]
  after_action :create_notify_hr_notification, only: [:notify_hr]
  after_action :create_submit_task_notification, only: [:submit_task]
  
  def approve
    return if @task.assign_task_to == current_user.id
    return redirect_to request.referrer, flash: { warning: "Employee not Submitted the task yet." } unless @task.submit
    
    if @task.approved
      redirect_to request.referrer, flash: { success: "already Approved" }
    else
      @task.approved = true
      @task.approved_by = current_user.id
      return redirect_to request.referrer, flash: {success: t("task.approve.success") } if @task.save(validate: false)
    end
  end
  
  def approved_task
    return unless admin? || hr?
    @tasks_approved = Task.filter_approved_task_by_priority(params[:priority], current_user)
  end  
  
  def user_assigned_task
    @tasks = Task.filter_user_assigned_task_by_priority(params[:priority], current_user)      
  end

  def create
    @task = Task.new(task_params)
    
    return redirect_to root_path if hr? || @task.user.admin || @task.user == current_user || @task.user.hr
    
    @task.assign_task_by = current_user.id
    @task.recurring_task = true unless task_params[:repeat] == "One_Time"
    if @task.save
      if params[:task_document].present?
        params[:task_document]["document"].each do |file|
          @task_document = @task.task_document.create(document: file, task_id: @task.id)
        end
      end
      redirect_to tasks_path flash: { success: t("task.success", task_name: @task.task_name, task_id: @task.id) }
    else
      render "new", flash: {danger: t("task.failed") }
    end
  end

  def destroy
    return unless admin? || @task.assign_task_to == current_user.id
    if @task.present?
      taskname= " id: " + @task.id.to_s + " " + @task.task_name
      @task.destroy
      redirect_to tasks_path, flash: { success: t("task.destroy", task: taskname) }
    else
      flash[:danger] = I18n.t "task.not_exist"
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

  def edit
    return redirect_to root_path unless @task.assign_task_by == current_user.id || admin?
  end

  def elastic_search
    return redirect_to request.referrer, flash: { danger: "Please enter a search term" } if params[:q].blank?
    @tasks = Task.task_search(params[:q], current_user)
  end  

  def index
    @tasks =  Task.filter_by_priority(params[:priority], current_user)
  end            
      
  def new
    @task = Task.new
  end
  
  def notify_hr
    return unless admin? && @task.approved
    
    @task.notify_hr = true
    @task.save
    redirect_to request.referrer, flash: { success: "A notification has been sent to all HR's" }
  end  

  def print_task_list
    return unless hr?
    @tasks = Task.notified_tasks
    respond_to do |format|
      format.html 
      format.pdf do
        pdf = TaskList.new(@tasks)
        send_data(pdf.render, filename: "Tasklist_#{DateTime.now.strftime("%d%m%Y%I%M%S")}.pdf", type: "application/pdf", disposition:"inline")
      end
    end
  end

  def print_task_details
    return unless hr? 
    @task = Task.find(params[:task_id])
    return unless @task.approved

    respond_to do |format|
      format.html 
      format.pdf do
        pdf = TaskDetails.new(@task)
        send_data(pdf.render, filename: "Task_#{@task.id}_#{DateTime.now.strftime("%d%m%Y%I%M%S")}.pdf", type: "application/pdf", disposition:"inline")
      end
    end
  end
  
  def show
    return redirect_to user_dashboard_path, flash: { danger: "You are trying to visit other employees task" } unless @task.assign_task_to == current_user.id || @task.assign_task_by == current_user.id || admin? || (@task.notify_hr && hr?)
  end
  
  def submit_subtask
    @subtask = SubTask.find(params[:id])
    return unless Task.find(@subtask.task_id).assign_task_to == current_user.id

    @subtask.submit = true
    @subtask.save
    redirect_to task_path(@subtask.task_id), flash: { success: t("task.submit_subtask.success", subtask: @subtask.name) }
  end  
  
  def submit_task
    return unless @task.assign_task_to == current_user.id
    return redirect_to request.referrer, flash: { warning: t("task.submit_task.failed") } unless SubTask.all_subtasks_submitted(@task)
    @task.submit = true
    
    return redirect_to request.referrer, flash: { success: t("task.submit_task.success") } if @task.save
  end  
  
  def update
    return redirect_to user_dashboard_path unless @task.assign_task_by == current_user.id || admin?
    return redirect_to user_dashboard_path if @task.approved && !admin?
    return redirect_to root_path if hr? || User.find(task_params[:assign_task_to]).admin || task_params[:assign_task_to] == current_user.id

    if task_params[:repeat] == "One_Time"
      @task.recurring_task = false
    else
      @task.recurring_task = true unless @task.submit
    end

    if @task.update(task_params)
      if params[:task_document].present?
        params[:task_document]["document"].each do |file|
          @task_document = @task.task_document.update(document: file, task_id: @task.id)
        end
      end
      redirect_to tasks_path, flash: { success: t("task.update_success", task_name: @task.task_name) }
    else
      render "edit", flash: { danger: t("task.failed") }
    end
  end

  private
  def category_list
    @categories ||= Category.all
  end

  def employee_list
    @users ||= User.all_except(current_user)
  end

  def create_approved_notification_and_email
    Notification.create_notification(@task.id, "approved")
    TaskMailerWorker.perform_async(@task.id,"approved")
    unless admin?
      Notification.create_notification(@task.id, "approved by")
      TaskMailerWorker.perform_async(@task.id,"approved by")
    end
  end

  def create_update_notification_and_email
    Notification.create_notification(@task.id, "updated")
    TaskMailerWorker.perform_async(@task.id,"update")
  end

  def create_mail_worker(task_id, type)
    TaskMailerWorker.perform_async(task_id,type)
  end

  def create_notify_hr_notification
    Notification.create_notification(@task.id, "notified")
  end

  def create_submit_task_notification
    Notification.create_notification(@task.id, "submitted")
  end

  def task_params
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy), task_document_attributes: [:id, :task_id, :document])
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
