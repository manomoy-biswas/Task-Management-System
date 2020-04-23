class UsersController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :check_user_is_admin, only: [:new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy, :profile]

  def index
    @users = User.all
  end

  def profile
    @user.picture=params[:picture]
    @user.save
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params) 
    @user.provider="google_oauth2"
    if user_params[:roles].present?
      if user_params[:roles].include?("hr")
        @user.hr = true
      end
    end

    if @user.save
      UserMailer.with(user: @user).welcome_user_email.deliver
      flash[:success] =  I18n.t "user.create_success"
      redirect_to users_path
    else
      flash[:danger] = I18n.t "user.create_faild"
      render "new"
    end
  end

  def edit
  end

  def show
  end

  def update
    if @user.update(user_params) 
      flash[:success] = I18n.t "user.update_success"
      redirect_to users_path
    else
      flash[:danger] = I18n.t "user.failed"
      render "edit"
    end
  end

  def destroy
    if @user.destroy
      flash[:success]=I18n.t "user.destroy_success"
      redirect_to users_path
    else
      flash[:success]=I18n.t "user.failed"
      redirect_to users_path
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :phone, :picture, :dob, roles:[])
  end
end
