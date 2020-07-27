class TasksController < ApplicationController
  include TasksHelper
  
  before_action :authenticate_user!
  before_action :check_user_is_hr, except: [:approved_task, :print_task_list, 
                :print_task_details, :show]
  before_action :set_task, only: [:approve, :destroy, :download, :edit, :notify_hr, :show,
                :submit_task, :update]
  after_action :create_approved_notification_and_email, only: [:approve]
  after_action :create_update_notification_and_email, only: [:update]
  after_action :create_notify_hr_notification, only: [:notify_hr]
  before_action :redirect_path, only: [:new, :edit, :show]
  
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
    return unless current_user.admin || current_user.hr
    @tasks_approved = Task.filter_approved_task_by_priority(params[:priority], current_user)
  end  
  
  def user_assigned_task
    @tasks = Task.filter_user_assigned_task_by_priority(params[:priority], current_user)      
  end

  def create
    @task = Task.new(task_params)
    return redirect_to root_path if current_user.hr || @task.user.admin || @task.user == current_user || @task.user.hr
    @task.assign_task_by = current_user.id
    @task.recurring_task = true unless task_params[:repeat] == "One_Time"
    if @task.save
      params[:task_document]["document"].each do |file|
        @task_document = @task.task_document.create(document: file, task_id: @task.id)
      end if params[:task_document].present?
      redirect_to session.delete(:return_to) || tasks_path, flash: { success: t("task.success", task_name: @task.task_name, task_id: @task.id) }
    else
      render "new", flash: {danger: t("task.failed") }
    end
  end

  def destroy
    return unless current_user.admin || @task.assign_task_to == current_user.id
    if @task.present?
      taskname= " id: " + @task.id.to_s + " " + @task.task_name
      @task.destroy
      redirect_to tasks_path, flash: { success: t("task.destroy", task: taskname) }
    else
      flash[:danger] = I18n.t "task.not_exist"
    end
  end
  
  def download
    begin
      if @task.task_document.count == 1
        data =  if Rails.env.production?
                  open(@task.task_document.first.document.url)
                else
                  open(@task.task_document.first.document.path)
                end
        send_data(data.read, filename: @task.task_document.first.document.file.filename)
      else
        folder_path = "#{Rails.root}/public/uploads/task_document/document/download/#{@task.id.to_s}/"
        filename = @task.task_name + "_TD_" + DateTime.parse(@task.created_at.to_s).strftime("%d%m%Y") +".zip"
        temp_file = Tempfile.new(filename)
        FileUtils.remove_dir(folder_path) if Dir.exist?(folder_path)
        Dir.mkdir(folder_path)
        @task.task_document.each do |file|
          open(folder_path + "#{file.document.file.filename}", 'wb') do |f|
            f << open("#{file.document.path}").read if Rails.env.development?
            f << open("#{file.document.url}").read if Rails.env.production?
          end
        end

        begin
          Zip::OutputStream.open(temp_file) { |zos| }
          Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
            @task.task_document.each do |file|
              zip.add(file.document.file.filename, File.join(folder_path, file.document.file.filename))
            end
          end
          read_data = File.read(temp_file.path)
          send_data(read_data, type: "application/zip", filename: filename)
        ensure
          FileUtils.remove_dir(folder_path) if Dir.exist?(folder_path)
          temp_file.close
          temp_file.unlink
        end
      end 
    rescue OpenURI::HTTPError
      redirect_to request.referrer, flash: { danger: "Somthing went wrong / File not found" }
    end
  end

  def edit
    redirect_to root_path unless @task.assign_task_by == current_user.id || current_user.admin
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
    return unless current_user.admin && @task.approved
    @task.notify_hr = true
    if @task.save
      Notification.create_notification(@task.id, "notified", current_user.id )
      redirect_to request.referrer, flash: { success: "A notification has been sent to all HR's" }
    end
  end  

  def print_task_list
    return unless current_user.hr
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
    return unless current_user.hr     
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
    return redirect_to user_dashboard_path, flash: { danger: "You are trying to visit other employees task" } unless @task.assign_task_to == current_user.id || @task.assign_task_by == current_user.id || current_user.admin || (@task.notify_hr && current_user.hr)
  end
  
  def submit_subtask
    @subtask = SubTask.find(params[:id])
    return unless Task.find(@subtask.task_id).assign_task_to == current_user.id
    @subtask.submit = true
    redirect_to task_path(@subtask.task_id), flash: { success: t("task.submit_subtask.success", subtask: @subtask.name) } if @subtask.save
  end  
  
  def submit_task
    return unless @task.assign_task_to == current_user.id
    return redirect_to request.referrer, flash: { warning: t("task.submit_task.failed") } unless SubTask.all_subtasks_submitted(@task)
    @task.submit = true 
    if @task.save 
      Notification.create_notification(@task.id, "submitted")
      return redirect_to request.referrer, flash: { success: t("task.submit_task.success") }
    end
  end  
  
  def update
    return redirect_to tasks_path, flash: { success: t("You dont have access to update this task") } if @task.assign_task_by != current_user.id && !current_user.admin
    return redirect_to root_path, flash: { success: t("Can't assign task to yourself or HR or ADMIN") } if current_user.hr || User.find(task_params[:assign_task_to]).admin || task_params[:assign_task_to] == current_user.id

    if task_params[:repeat] == "One_Time"
      @task.recurring_task = false
    else
      @task.recurring_task = true unless @task.submit
    end

    if @task.update(task_params)
      if params[:task_document].present?
        @task.task_document.destroy_all
        params[:task_document]["document"].each do |file|
          @task_document = @task.task_document.create(document: file, task_id: @task.id)
        end 
      end
      redirect_to session.delete(:return_to), flash: { success: t("task.update_success", task_name: @task.task_name) }
    else
      render "edit", flash: { danger: t("task.failed") }
    end
  end

  private

  def redirect_path
    session[:return_to] = request.referer
  end

  def create_approved_notification_and_email
    Notification.create_notification(@task.id, "approved")
    TaskMailerWorker.perform_async(@task.id,"approved")
    unless current_user.admin
      Notification.create_notification(@task.id, "approved by")
      TaskMailerWorker.perform_async(@task.id,"approved by")
    end
  end

  def create_update_notification_and_email
    Notification.create_notification(@task.id, "updated")
    TaskMailerWorker.perform_async(@task.id, "update")
  end

  def create_notify_hr_notification
    Notification.create_notification(@task.id, "notified", current_user.id )
  end

  def task_params
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy), task_document_attributes: [:id, :task_id, :document])
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
