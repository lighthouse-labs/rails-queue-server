class EvaluationSerializer < ActiveModel::Serializer

  format_keys :lower_camel
  root false

  attributes :id, :created_at, :github_url, :resubmission, :started_at, :completed_at, :due, :state, :student_notes, :type

  has_one :project, serializer: ProjectSerializer
  has_one :student, serializer: UserSerializer
  has_one :teacher, serializer: UserSerializer

  def type
    'ProjectEvaluation'
  end

end
