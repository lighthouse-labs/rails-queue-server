class AddOptimizedIndexForSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_index :activity_submissions, [:user_id, :cohort_id, :activity_id], name: 'index_activity_submissions_on_user_and_cohort_and_activity_id'
  end
end
