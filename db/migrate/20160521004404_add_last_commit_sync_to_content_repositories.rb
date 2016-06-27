class AddLastCommitSyncToContentRepositories < ActiveRecord::Migration
  def change
    add_column :content_repositories, :last_sha, :string
  end
end
