class AssistanceRequestSerializer < ActiveModel::Serializer

  format_keys :lower_camel
  attributes :id, :reason, :start_at, :position_in_queue

  has_one :activity, serializer: ActivitySerializer
  has_one :requestor, serializer: UserSerializer

end
