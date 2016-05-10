class RenameUrlToGitHubUrlOnEvaluation < ActiveRecord::Migration
  def change
    rename_column :evaluations, :url, :github_url
  end
end
