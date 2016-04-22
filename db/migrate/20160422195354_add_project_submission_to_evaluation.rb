class AddProjectSubmissionToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :project_submission, :string
  end
end
