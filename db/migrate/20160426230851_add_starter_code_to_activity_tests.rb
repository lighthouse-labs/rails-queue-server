class AddStarterCodeToActivityTests < ActiveRecord::Migration
  def change
    add_column :activity_tests, :initial_code, :text
  end
end
