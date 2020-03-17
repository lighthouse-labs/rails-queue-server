class QueueAssistanceSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :start_at, :type, :conference_link

  has_one :assistance_request, serializer: AssistanceRequestSerializer
  has_one :assistor, serializer: UserSerializer
  has_one :assistee, serializer: UserSerializer
  has_one :activity, serializer: ActivitySerializer

  def type
    'Assistance'
  end

end
