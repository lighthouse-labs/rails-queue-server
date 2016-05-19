class EvaluationSerializer < ActiveModel::Serializer
  attributes :id

  has_one :project, serializer: ProjectSerializer
  has_one :student, serializer: UserSerializer
end
