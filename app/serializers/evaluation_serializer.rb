class EvaluationSerializer < ActiveModel::Serializer

  root false

  attributes :id, :created_at, :github_url, :resubmission
  has_one :project, serializer: ProjectSerializer
  has_one :student, serializer: UserSerializer

  def attributes
    attributes = super
    attributes[:teacher] = UserSerializer.new(object.teacher) if object.teacher
    attributes
  end

  def created_at
    object.created_at.to_s
  end

end
