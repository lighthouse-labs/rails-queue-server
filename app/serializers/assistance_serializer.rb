class AssistanceSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel
  attributes :id, :start_at, :end_at, :notes, :rating, :student_notes, :flag, :conference_link, :conference_type, :assistor

  has_one :feedback, serializer: FeedbackSerializer

  def assistor
    UserSerializer.new(object.assistor)
  end

end
