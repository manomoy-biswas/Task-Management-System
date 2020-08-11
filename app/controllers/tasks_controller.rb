class TasksController < ApplicationController
  include TasksHelper
  layout "dashboard"
  before_action :authenticate_user!
  before_action :check_user_is_hr, only: [:print_task_list, :print_task_details]
  before_action :set_task, only: [:approve, :destroy, :download, :edit, :notify_hr, :show,
                :submit_task, :update]
  before_action :redirect_path, only: [:new, :edit, :show]
  
  def approve
    return if @task.assign_task_to == current_user.id
    return redirect_to request.referrer, flash: { warning: "Employee not Submitted the task yet." } unless @task.submit
    
    if @task.approved
      redirect_to request.referrer, flash: { success: "already Approved" }
    else
      @task.approved = true
      @task.approved_by = current_user.id
      if @task.save(validate: false)
        redirect_to request.referrer, flash: {success: t("task.approve.success") }
        Notification.create_notification(@task.id, "approved")
        TaskMailerWorker.perform_async(@task.id,"approved")
        unless current_user.admin
          Notification.create_notification(@task.id, "approved by")
          TaskMailerWorker.perform_async(@task.id,"approved by")
        end
      end
    end
  end
  
  def approved_task
    @tasks = Task.fetch_approved_tasks(params[:priority], params[:query],current_user)
  end  
  
  def user_assigned_task
    @tasks = Task.fetch_user_assigned_tasks(params[:priority], params[:query], current_user)      
  end

  def create
    @task = Task.new(task_params)
    return redirect_to overview_path if @task.user == current_user || (current_user.hr && !@task.user.hr) || ((!current_user.admin && !current_user.hr) && (@task.user.hr || @task.user.admin)) 
    
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
    redirect_to overview_path unless @task.assign_task_by == current_user.id || current_user.admin
  end

  def index
    @tasks =  Task.fetch_tasks(params[:priority], params[:query], current_user)
  end            
      
  def new
    @task = Task.new
  end

  def notified_task
    return redirect_to overview_path, flash: { danger: "Yoou don't have assess to this page" } unless current_user.admin || current_user.hr
    @tasks = Task.fetch_notified_tasks(params[:priority], params[:query])
  end

  def notify_hr
    return unless current_user.admin && @task.approved
    @task.notify_hr = true
    if @task.save
      Notification.create_notification(@task.id, "notified", current_user.id )
      Task.send_notified_email(@task.id)
    end
  end  

  def print_task_list
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
    return redirect_to overview_path, flash: { danger: "You are trying to visit other employees task" } unless @task.assign_task_to == current_user.id || @task.assign_task_by == current_user.id || current_user.admin || (@task.notify_hr && current_user.hr)
  end
  
  def submit_subtask
    @subtask = SubTask.find(params[:id])
    return unless @subtask.task.assign_task_to == current_user.id
    @subtask.submit = true
    @subtask.save
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
    return redirect_to tasks_path, flash: { success: "You dont have access to update this task" } unless @task.assign_task_by == current_user.id || current_user.admin
    return redirect_to tasks_path, flash: { success: "Can't assign task to yourself or ADMIN" } if (User.find(@task.assign_task_to).admin && !current_user.admin) || @task.assign_task_to == current_user.id

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
      Notification.create_notification(@task.id, "updated")
      TaskMailerWorker.perform_async(@task.id, "update")
      redirect_to session.delete(:return_to), flash: { success: t("task.update_success", task_name: @task.task_name) }
    else
      render "edit", flash: { danger: t("task.failed") }
    end
  end

  private

  def redirect_path
    session[:return_to] = request.referer
  end

  def task_params
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat,sub_task_attributes: SubTask.attribute_names.map(&:to_sym).push(:_destroy), task_document_attributes: [:id, :task_id, :document])
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
