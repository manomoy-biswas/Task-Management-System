class UsersController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!, :check_user_is_admin
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) 
    if user_params[:roles].present?
      if user_params[:roles].include?("hr")
        @user.hr = true
      end
    end
    if @user.save
      flash[:notice] = "User record added Successfully."
      redirect_to users_path
    else
      flash[:alert] = "Some error occcured. Please try again."
      render "new"
    end
  end

  def edit
  end

  def update
    if @user.update(user_params) 
      flash[:notice] = ' User record updated successfully.'
      redirect_to users_path
    else
      flash[:alert] = "Some error occcured. Please try again."
      render "edit"
    end
  end

  def destroy
    @user.destroy
    flash[:notice]="User record deleted successfully"
    redirect_to users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :phone, :dob, roles:[])
  end
end
