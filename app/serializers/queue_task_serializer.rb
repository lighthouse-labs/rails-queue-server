class QueueTaskSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes  :id,
              :assistor,
              :state,
              :start_at,
              :created_at,
              :assistance

  has_one :assistance_request, serializer: AssistanceRequestSerializer

  def assistor
    UserSerializer.new(object.assistor)
  end

  def assistance
    AssistanceSerializer.new(object.assistance_request.assistance)
  end

  protected

end
