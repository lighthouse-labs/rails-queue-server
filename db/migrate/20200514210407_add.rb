class Add < ActiveRecord::Migration[5.0]
  def change
    add_column :assistances, :resource_type, :string
  end
end
