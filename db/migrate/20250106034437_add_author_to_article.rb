class AddAuthorToArticle < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :author, :string
  end
end
