class QueueTaskSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes  :id,
              :teacher,
              :state,
              :started_at,
              :type
  has_one :assistance_request, serializer: NationalQueueAssistanceRequestSerializer

  protected

  def teacher
    # add more so serializer can be used on evaluations and tech interviews
    teacher = object.user
    UserSerializer.new(teacher).as_json
  end

  def state
    object.state
  end

  def started_at
    object.assistance_request.start_at
  end

  def type
    'Assistance'
  end

end
