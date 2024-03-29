class CreateArticlesCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :articles_categories, do |t|
      t.belongs_to :article
      t.belongs_to :category

      t.timestamps
      add_index :articles_categories, :article_id
      add_index :articles_categories, :category_id
    end
  end
end
