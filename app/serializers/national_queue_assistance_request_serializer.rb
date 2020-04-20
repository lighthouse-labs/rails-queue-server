class NationalQueueAssistanceRequestSerializer < ActiveModel::Serializer
  root false
  format_keys :lower_camel
  attributes :id, :reason, :start_at, :position_in_queue, :canceled_at, :state, :assistor, :conference_link

  has_one :activity, serializer: ActivitySerializer
  has_one :requestor, serializer: UserSerializer

  def state
    object.state
  end

  def assistor
    UserSerializer.new(object.assistance.assistor).as_json if object.assistance&.assistor
  end

  def conference_link
    object.assistance&.conference_link
  end
  
end
