class AddDeletedAtToContentRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :content_repositories, :deleted_at, :datetime
    add_index :content_repositories, :deleted_at
  end
end
