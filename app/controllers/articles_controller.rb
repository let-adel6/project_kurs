class ArticlesController < ApplicationController
  before_action :set_categories
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :show]
  def index
    if params[:search].present? || params[:category_id].present?
      @articles = search_articles.page(params[:page]).per(5)
    else
      @articles = Article.includes(:categories).page(params[:page]).per(5)
    end

    @categories = Category.all
   
  end

  def show
    @article = Article.find(params[:id])
    @categories = @article.categories
  end

  def new
    @article = Article.new
    @categories = Category.all
  end

  def create
    @article = Article.new(article_params)
    @article.user = current_user
    @user = @article.user.email
    if @article.save
      @message = "Новый пост создан: #{@article.title}"
      redirect_to controller: 'bots', action: 'client', message: @message, article: @article, user: @user 
    else
        @categories=Category.all.order(:name)
        render 'new', categories: @categories
    end
  end
  def edit
    @article = Article.find(params[:id])
    @categories = @article.categories
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path
  end

  private
  def search_articles
    if params[:search].present? && params[:category_id].present?
      Article.joins(:categories)
             .where("articles.title LIKE ?", "%#{params[:search]}%",)
             .where(categories: { id: params[:category_id] })
    elsif params[:search].present?
      Article.where("title LIKE ?", "%#{params[:search]}%")
    elsif params[:category_id].present?
      Article.joins(:categories).where(categories: { id: params[:category_id] })
    else
      Article.includes(:categories).all
    end
  end

  def set_categories
    @categories = Category.all
  end
  
  def article_params
    params.require(:article).permit(:title, :body, :status, category_ids: [])
  end
  
end

