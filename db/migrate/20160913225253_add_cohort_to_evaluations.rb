class AddCohortToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluations, :cohort_id, :integer
    add_index  :evaluations, :cohort_id
  end
end
