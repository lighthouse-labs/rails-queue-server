class AssignCohortIdToEvaluations < ActiveRecord::Migration[5.0]
  def up
    Evaluation.find_each(batch_size: 100) do |eval|
      c = eval.student.try :cohort
      eval.update_column(:cohort_id, c.try(:id))
    end
  end
  def down
    # nothing to do
  end
end
