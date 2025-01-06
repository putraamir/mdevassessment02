class ArticlesController < ApplicationController
  def index
    @articles = Article.order(published_at: :desc)
  end
end
