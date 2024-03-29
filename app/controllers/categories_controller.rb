class CategoriesController < ApplicationController
   
    before_action :authenticate_user!
    def new
      @category = Category.new
      @categories = Category.all
    end
  
    def create
      @category = Category.new(category_params)
      if @category.save
        @message = "Новая категория создана: #{@category.name}"
        redirect_to controller: 'bots', action: 'client', message: @message, category: @category
      else
        render 'edit'
      end
    end

    def destroy
      @category = Category.find(params[:id])
      @category.destroy
      redirect_to root_path, notice: "Категория успешно удалена."
    end
    
    private
  
    def category_params
      params.require(:category).permit(:name, :description) 
    end
end
