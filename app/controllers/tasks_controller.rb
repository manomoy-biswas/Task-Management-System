class TasksController < ApplicationController
  before_action :authenticate_user!, :
  def index
    @Tasks = Task.all
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def show
  end

  def destroy
  end
  private
end
