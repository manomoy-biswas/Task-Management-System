class HomeController < ApplicationController
  layout "dashboard", only: [:overview]
  before_action :authenticate_user!, only: [:overview]
  def index
  end
  def overview
    if current_user.admin
      @tasks = Task.all.includes(:user, :assign_by, :category).order("created_at DESC").limit(3) 
      @approved_tasks = Task.approved_tasks.order("updated_at DESC").limit(3) 
    else
      @tasks = current_user.tasks.includes(:assign_by, :category).order("created_at DESC").limit(3)
      @approved_tasks = Task.users_approved_tasks(current_user.id).order("created_at DESC").limit(3)
    end
  end
end
