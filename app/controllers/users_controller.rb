class UsersController < ApplicationController
  include ApplicationHelper
  before_action :authenticate_user!
  before_action :check_user_is_admin, only: [:new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy]

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
  
  def destroy
    return unless admin?

    if @user.destroy
      flash[:success]=I18n.t "user.destroy_success"
      redirect_to users_path
    else
      flash[:success]=I18n.t "user.failed"
      redirect_to users_path
    end
  end

  def edit
    unless admin?
      if @user.id != current_user.id
        redirect_to root_path
      end
    end
  end    

  def index
    unless admin? || hr?
      redirerct_to root_path
    end
    @users =  if !params[:role] || params[:role] == ""
                if admin?
                  User.all.order("name ASC")
                elsif hr?
                  User.where.not(admin: 1).order("name ASC")
                end
              elsif params[:role] == "Admin"
                User.all_admin.order("name ASC")
              elsif params[:role] == "HR"
                User.all_hr.order("name ASC")
              else
                User.all_employee.order("name ASC")
              end    
  end    
  
  def new
    @user = User.new
  end  
  
  def print_user_list
    return unless hr?
    @users = User.all_users_except_admin.order("name ASC")
    respond_to do |format|
      format.html 
      format.pdf do
        pdf = UserList.new(@users)
        send_data(pdf.render, filename: "Userlist_#{DateTime.now.strftime("%d%m%Y%I%M%S")}.pdf", type: "application/pdf", disposition:"inline")
      end
    end
  end

  def show
  end  

  def update
    if admin? && @user != current_user
      if @user.update(user_params) 
        flash[:success] = I18n.t "user.update_success"
        redirect_to users_path
      else
        flash[:danger] = I18n.t "user.failed"
        render "edit"
      end
    elsif @user == current_user
      @user.name = user_params[:name] if user_params[:name]
      @user.dob = user_params[:dob] if user_params[:dob]
      @user.phone = user_params[:phone] if user_params[:phone]
      @user.avater = user_params[:avater] if user_params[:avater].present?
      if @user.save
        flash[:success] = I18n.t "user.update_success"
        redirect_to user_path(@user)
      end
    end
  end  

  private

  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :phone, :dob, :avater, roles:[])
  end
end
