class MakeErrorMessageIntoTextForDeployments < ActiveRecord::Migration
  def up
    change_column :deployments, :error_message, :text
  end

  def down
    change_column :deployments, :error_message, :string, limit: 1000
  end
end
