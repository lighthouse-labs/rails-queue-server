class RemoveProjectSubmissionFromEvaluations < ActiveRecord::Migration
  def change
    remove_column :evaluations, :project_submission
  end
end
