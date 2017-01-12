class AddFinalScoreToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluations, :final_score, :integer # 1 = reject, 2,3,4 are pass of varying degrees
  end
end
