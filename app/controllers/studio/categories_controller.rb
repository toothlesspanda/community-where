module Studio
  class CategoriesController < BaseController
    before_action :set_category, only: %i[edit update destroy]

    def index
      @parents = Category.where(parent_id: nil).includes(:children).order(:code)
      @orphans = Category.with_parent.where.not(parent_id: @parents.select(:id)).order(:code)
    end

    def new
      @category = Category.new(parent_id: params[:parent_id])
      @parents = Category.where(parent_id: nil).order(:code)
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to studio_categories_path, notice: "Category created."
      else
        @parents = Category.where(parent_id: nil).order(:code)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @parents = Category.where(parent_id: nil).where.not(id: @category.id).order(:code)
    end

    def update
      if @category.update(category_params)
        redirect_to studio_categories_path, notice: "Category updated."
      else
        @parents = Category.where(parent_id: nil).where.not(id: @category.id).order(:code)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to studio_categories_path, notice: "Category deleted."
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:code, :parent_id, :hex_color, :icon, code_translations: {})
    end
  end
end
