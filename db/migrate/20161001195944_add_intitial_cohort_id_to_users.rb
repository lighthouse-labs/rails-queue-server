class AddIntitialCohortIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :initial_cohort_id, :integer
    add_index :users, :initial_cohort_id
  end
end
