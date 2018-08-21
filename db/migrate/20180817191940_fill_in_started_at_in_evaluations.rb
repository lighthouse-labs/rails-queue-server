class FillInStartedAtInEvaluations < ActiveRecord::Migration[5.0]
  def up
    Evaluation.auto_accepted.update_all("started_at = completed_at")
  end

  def down
    Evaluation.auto_accepted.update_all(started_at: nil)
  end
end
