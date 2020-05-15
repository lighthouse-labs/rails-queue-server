class QueueTaskSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes  :id,
              :assistor,
              :state,
              :start_at,
              :created_at

  has_one :assistance_request, serializer: AssistanceRequestSerializer

  def assistor
    UserSerializer.new(object.assistor).to_json
  end

  protected

end
