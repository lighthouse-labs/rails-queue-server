class AddMoreIndicesOnUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :type
    add_index :users, [:type, :on_duty]
  end
end
