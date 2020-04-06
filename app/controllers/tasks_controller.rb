class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :category_list, :employee_list, only: [:create, :edit, :update, :new]
  before_action :set_task, only: [:edit,:update,:destroy]
  def index
    @Tasks = Task.all
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
    params.required(:task).permit(:task_category, :priority,:task_name, :description, :submit_date, :assign_task_to, :repeat, :document)
  end
  def set_task 
    @task = Task.find(params[:id])
  end
end
