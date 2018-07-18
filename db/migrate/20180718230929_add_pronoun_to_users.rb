class AddPronounToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pronoun, :string
  end
end
