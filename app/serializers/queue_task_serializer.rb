class QueueTaskSerializer < ActiveModel::Serializer

  format_keys :lower_camel
  root true

  attributes  :sequence,
              :in_progress

  has_one :teacher, serializer: UserSerializer
  has_one :assistance_request, serializer: AssistanceRequestSerializer

  protected

  def in_progress
    object.in_progress?
  end

end
