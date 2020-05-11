class AddSecretToCompassInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :compass_instances, :secret, :string
  end
end
