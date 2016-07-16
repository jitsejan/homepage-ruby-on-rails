class ArticlesController < ApplicationController
  def autocomplete
    render json: Article.search(params[:query], autocomplete: true, limit: 10).map(&:title)
  end
  
  def index
    if params[:query].present?
      @articles = Article.search(params[:query])
    else
      @articles = Article.order("published_at DESC")
    end
  end

  def show
    @article = Article.query(params[:title])
  end
end
