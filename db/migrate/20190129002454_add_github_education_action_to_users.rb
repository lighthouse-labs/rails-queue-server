class AddGithubEducationActionToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :github_education_action, :string
  end
end
