class AddBranchToDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :branch, :string
  end
end
