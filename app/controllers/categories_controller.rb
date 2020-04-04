class CategoriesController < ApplicationController
  before_action :authenticate_user!, :check_user_is_admin
  before_action :set_category, only: [:edit, :update, :destroy]
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = I18n.t "categories.add_success"
      redirect_to categories_path
    else
      flash[:danger] = I18n.t "categories.faild"
      render "new"
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      flash[:success] = I18n.t "categories.update_success"
      redirect_to categories_path
    else
      flash[:danger] = I18n.t "categories.faild"
      render "edit"
    end
  end

  def destroy
    if @category.destroy
      flash[:success]=I18n.t "category.destroy_success"
    else
      flash[:success]=I18n.t "category.faild"
    end
    redirect_to categories_path
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
