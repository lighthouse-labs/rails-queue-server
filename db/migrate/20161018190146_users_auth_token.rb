class UsersAuthToken < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :auth_token, null: false, default: ""
      t.index :auth_token
    end
  end
end
