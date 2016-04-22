class Evaluation < ActiveRecord::Base

  mount_uploader :project_submission, ProjectSubmissionUploader

  belongs_to :project

  belongs_to :student

  belongs_to :teacher

end
