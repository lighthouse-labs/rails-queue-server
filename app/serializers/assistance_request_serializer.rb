class AssistanceRequestSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel
  attributes :id, :requestor, :request, :start_at, :canceled_at, :type

  # has_one :compass_instance, serializer: CompassInstanceSerializer
  delegate :state, to: :object

  def assistor
    UserSerializer.new(object.assistance.assistor).as_json if object.assistance&.assistor
  end

  def conference_link
    object.assistance&.conference_link
  end

  def assistance_start
    object.assistance&.start_at
  end
end
