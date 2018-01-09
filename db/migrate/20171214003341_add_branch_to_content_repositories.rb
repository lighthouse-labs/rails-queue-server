class AddBranchToContentRepositories < ActiveRecord::Migration[5.0]
  def change
    add_column :content_repositories, :github_branch, :string, default: "master"
  end
end
