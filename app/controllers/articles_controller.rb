class ArticlesController < ApplicationController
  def index
    @articles = Article.order("published_at DESC")
  end

  def show
    @article = Article.find(params[:id])
  end
end
