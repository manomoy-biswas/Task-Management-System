class InvitationsController < ApplicationController
  include SessionsHelper
  before_action :authenticate_user!, :check_user_is_admin, only: [:new, :create, :destroy]
  layout "dashboard", only: [:index, :new]
  before_action :set_invite, only: [:edit, :update]

  def new
  @invite = Invitation.new
  end

  def create
    @invite =Invitation.new(invite_params)
    @invite.invitation_token = Invitation.generate_token
    redirect_to invitations_path, flash: {success: "Email sent with invitation instructions."} if @invite.save
  end
  
  def destroy
    @invite = Invitation.find(params[:id])
    @invite.destroy
    redirect_to request.referrer
  end

  def edit
    @user = User.new
  end

  def index
    @invitations =Invitation.all
  end

  def update
    return redirect_to root_path, flash: {danger: "Already Joined"} if @invite.status.downcase == "accepted"
    return redirect_to root_path, flash: {danger: "Invitation link has expired." } if @invite.created_at < 3.days.ago
    @user = User.new(user_params)
    if user_params[:password] == user_params[:password_confirmation]
      @user.admin = true
      if @user.save
        @invite.status = "accepted"
        @invite.save(validate: false)
        User.generate_auth_token(:auth_token, @user)
        login(@user)
        redirect_to overview_path, flash: {success: "Wencome #{@user.name}"}
      else
        render "edit"
      end
    else
      render "edit", flash: {warning: "Password does not match"}
    end
  end
  
  private
   
  def set_invite
    @invite = Invitation.find_by_invitation_token!(params[:id])
  end
  def user_params
    params.require(:user).permit(:name, :email, :phone, :dob, :password, :password_confirmation)
  end
  def new_params
    params.require(:user).permit(:email)
  end
  def invite_params
    params.require(:invitation).permit(:name, :email)
  end
end
