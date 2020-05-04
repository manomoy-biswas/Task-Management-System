class TasksController < ApplicationController
  require "zip"
  include TasksHelper
  
  before_action :authenticate_user!
  before_action :check_user_is_hr, except: [:approved_task, :print_task_list, 
                :print_task_details, :show]
  before_action :category_list, :employee_list, only: [:new, :create, :edit, :update]
  before_action :set_task, only: [:approve, :destroy, :download, :edit, :notify_hr, :show,
                :submit_task, :update]
  
  def approve
    return if @task.assign_task_to == current_user.id

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
  
  def approved_task
    return unless admin? || hr?

    @tasks_approved = if admin?
                        if !params[:priority] || params[:priority] == ""
                          Task.approved_tasks.order("created_at DESC")
                        else
                          Task.approved_tasks_filter(params[:priority]).order("created_at DESC")
                        end
                      elsif hr?
                        if !params[:priority] || params[:priority] == ""
                          Task.notified_tasks.order("created_at DESC")
                        else
                          Task.notified_tasks_filter(params[:priority]).order("created_at DESC")
                        end
                      end
  end  
  
  def user_assigned_task
    @tasks =  if !params[:priority] || params[:priority] == ""
                Task.my_assigned_tasks(current_user.id).order("created_at DESC")
              else
                Task.my_assigned_tasks_filter(params[:priority],current_user.id).order("created_at DESC")
              end       
  end

  def create
    @task = Task.new(task_params)
    
    if hr? || @task.user.admin || @task.user == current_user || @task.user.hr 
      redirect_to root_path
    end
    
    @task.assign_task_by = current_user.id
    # @task.submit_date = task_params[:submit_date].to_datetime
    unless task_params[:repeat] == "One_Time"
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

  def destroy
    return unless admin? || @task.assign_task_to == current_user.id
    if @task.present?
      taskname= " id: " + @task.id.to_s + " " + @task.task_name
      @task.destroy
      flash[:success] = I18n.t "task.destroy", task: taskname
      redirect_to tasks_path
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
    unless @task.assign_task_by == current_user.id || admin?
      redirect_to root_path
    end
  end

  def elastic_search
    if params[:q].blank?
      flash[:danger] = "Please enter a search term"
      redirect_to tasks_path
      return
    end  
    if admin?
      @tasks = Task.all_task_search(params[:q].present? ? params[:q] : nil)
    else
      @tasks = Task.search((params[:q].present? ? params[:q] : nil), current_user.id)
    end  
  end  

  def index
    @tasks =  if admin?
                if !params[:priority] || params[:priority] == ""
                  Task.includes(:user, :assign_by, :category).order("created_at DESC")
                else
                  Task.admin_task_filter(params[:priority]).includes(:user, :assign_by, :category).order("created_at DESC")
                end    
              else
                if !params[:priority] || params[:priority] == ""
                  current_user.tasks.includes(:assign_by, :category).order("created_at DESC")
                else
                  Task.my_task_filter(params[:priority], current_user.id).includes(:assign_by, :category).order("created_at DESC")
                end
              end
  end            
      
  def new
    @task = Task.new
  end
  
  def notify_hr
    return unless admin? && @task.approved
    
    @task.notify_hr = true
    @task.save
    flash[:success] = "A notification has been sent to all HR's"
    Notification.create_notification(@task.id, "notified")
    redirect_to request.referrer
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
    unless @task.assign_task_to == current_user.id || @task.assign_task_by == current_user.id || admin? || (@task.notify_hr && hr?)
      flash[:danger] = "You are trying to visit other employees task"
      redirect_to user_dashboard_path
    end
  end
  
  def submit_subtask
    @subtask = SubTask.find(params[:id])
    return unless Task.find(@subtask.task_id).assign_task_to == current_user.id

    @subtask.submit = true
    @subtask.save
    flash[:success] = I18n.t "task.submit_subtask.success", subtask: @subtask.name
    redirect_to task_path(@subtask.task_id)
  end  
  
  def submit_task
    return unless @task.assign_task_to == current_user.id
      
    unless SubTask.all_subtasks_submitted(@task)
      flash[:warning] = I18n.t "task.submit_task.failed"
      redirect_to request.referrer
      return
    end  
    @task.submit = true
    if @task.save
      Notification.create_notification(@task.id, "submitted")
      flash[:success] = I18n.t "task.submit_task.success"
      redirect_to request.referrer
    end
  end  
  
  def update
    unless @task.assign_task_by == current_user.id || admin?
      redirect_to user_dashboard_path
      return
    end
    if @task.approved && !admin?
      redirect_to user_dashboard_path
      return
    end
    
    if hr? || User.find(task_params[:assign_task_to]).admin || task_params[:assign_task_to] == current_user.id
      redirect_to root_path
    end

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
      Notification.create_notification(@task.id, "updated")
      TaskMailerWorker.perform_async(@task.id,"update")
      flash[:success] = I18n.t "task.update_success", task_name: @task.task_name
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t "task.failed"
      render "edit"
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

  def set_task
    @task = Task.find(params[:id])
  end
end
