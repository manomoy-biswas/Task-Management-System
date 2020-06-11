class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_is_admin, only: [:new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy]

  def create
    @user = User.new(user_params) 
    if @user.save
      UserMailer.with(user: @user).welcome_user_email.deliver
      redirect_to users_path, flash: { success: t(".create_success") }
    else
      render "new", flash: { danger: t("user.create_faild") }
    end  
  end  
  
  def destroy
    return unless admin?
    if @user.destroy
      redirect_to users_path, flash: {success: t("user.create_success")}
    else
      redirect_to users_path, flash: {success: t("user.failed")}
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
    redirerct_to root_path unless admin? || hr?
    @users =  User.filter_by_role(params[:role], current_user) 
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
        redirect_to users_path, flash: { success: t("user.update_success") }
      else
        render "edit", flash: { danger: t("user.failed")}
      end
    elsif @user == current_user
      @user.name = user_params[:name] if user_params[:name]
      @user.dob = user_params[:dob] if user_params[:dob]
      @user.phone = user_params[:phone] if user_params[:phone]
      @user.avater = user_params[:avater] if user_params[:avater].present?
      redirect_to user_path(@user), flash: { success: t("user.update_success") } if @user.save
    end
  end  

  private

  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :phone, :dob, :avater, :hr)
  end
end
