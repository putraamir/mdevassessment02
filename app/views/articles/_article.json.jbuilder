json.extract! article, :id, :title, :url, :published_at, :created_at, :updated_at
json.url article_url(article, format: :json)
