class AddProgrammingTestToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :programming_test_id, :integer
    add_foreign_key :activities, :programming_tests
  end
end
