class Article < ApplicationRecord
  validates :title, presence: true
  validates :published_at, presence: true
end
