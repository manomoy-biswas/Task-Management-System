class TasksController < ApplicationController
  before_action :authenticate_user!
  include TasksHelper

  before_action :category_list, :employee_list, only: [:create, :edit, :update, :new]
  before_action :set_task, only: [:edit, :update, :show, :destroy]
  before_action :task_list
  def index
    @Tasks = Task.all
  end
  
  def task_list
    @priority = params[:priority]
    unless current_user.admin
      @Tasks_list =  current_user.tasks
      # Task.where(assign_task_to: current_user)
    else
      @Tasks_list =  Task.all
    end
  end

  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(task_params)
    @task.assign_task_by = current_user.id
    # @task.submit_date = task_params[:submit_date].to_datetime
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true
    end
    if @task.save
      flash[:success]= I18n.t "task.success", taskname: @task.task_name, taskid: @task.id
      redirect_to tasks_path
    else
      flash[:danger] = I18n.t "task.faild"
      render "new"
    end
  end


  def edit
  end

  def update
    unless task_params[:repeat] == "One Time"
      @task.recurring_task = true unless @task.submit
    else
      @task.recurring_task = false
    end

    if @task.update(task_params)
      flash[:success] = I18n.t "task.update_success", taskname: @task.task_name
      redirect_to task_path(@task)
    else
      flash[:danger] = I18n.t "task.failed"
      render "edit"
    end
  end

  def show
  end

  def destroy
    taskname= " id: "+@task.id.to_s + @task.task_name 
    @task.destroy
    flash[:notice] = I18n.t "task.destroy", task: taskname
    redirect_to tasks_path
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
