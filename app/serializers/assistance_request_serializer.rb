class AssistanceRequestSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel
  attributes :id, :requestor, :request, :start_at, :canceled_at, :type, :state, :compass_instance

  # has_one :compass_instance, serializer: CompassInstanceSerializer
  delegate :state, to: :object

  def compass_instance
    object.compass_instance.name
  end

end
