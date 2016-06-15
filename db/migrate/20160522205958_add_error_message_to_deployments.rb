class AddErrorMessageToDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :error_message, :string, limit: 1000
  end
end
