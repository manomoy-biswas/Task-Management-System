class CategoriesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!, :check_user_is_admin
  before_action :set_category, only: [:edit, :update, :destroy]

  def create
    @category = Category.new(category_params)
    return redirect_to categories_path, flash: { success: t("categories.add_success") } if @category.save
    render "new", flash: { danger: t("categories.faild") }
  end
  
  def destroy
    return redirect_to categories_path, flash: { success: t("category.destroy_success") } if @category.destroy
    flash[:danger]=I18n.t "category.faild"
  end
  
  def edit
  end
  
  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
  end

  def update
    return redirect_to categories_path, flash: { success: t("categories.update_success") } if @category.update(category_params)
    render "edit", flash: { danger: t("categories.faild") }
  end
  
  private

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
