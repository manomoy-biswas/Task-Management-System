class UsersController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
  before_action :check_user_is_admin, only: [:new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy]

  def create
    @user = User.new(user_params) 
    if user_params[:role] == "Admin"
      @user.admin = true
    elsif user_params[:role] == "HR"
      @user.hr = true
    end
    return redirect_to users_path, flash: { success: t("user.create_success") } if @user.save
    render "new", flash: { danger: t("user.create_faild") }
  end  
  
  def destroy
    return unless current_user.admin
    begin
      return redirect_to users_path, flash: {success: t("user.destroy_success")} if @user.destroy
    rescue
      redirect_to users_path, flash: { danger: "Can not delete this user. One or more task is associated with this user." }
    end
  end

  def edit
    redirect_to root_path if !current_user.admin && @user.id != current_user.id
  end    

  def index
    redirect_to root_path unless current_user.admin || current_user.hr
    @users =  User.fetch_user(params[:role], params[:query], current_user)
  end    
  
  def new
    @user = User.new
  end  
  
  def print_user_list
    return unless current_user.hr
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

  def search
    if params[:query].present?
      user_ids = User.search(params[:query]).map(&:id)
      @users = User.where(id: user_ids).order("name ASC")
      redirect_to users_path(@users)
    end
  end

  def update
    if current_user.admin && @user != current_user
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
    params.require(:user).permit(:name, :email, :phone, :dob, :avater, :role)
  end
end
