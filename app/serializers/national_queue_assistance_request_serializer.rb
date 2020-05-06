class NationalQueueAssistanceRequestSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel
  attributes :id, :reason, :start_at, :position_in_queue, :canceled_at, :state, :assistor, :conference_link, :assistance_start, :assistor_rating

  has_one :activity, serializer: ActivitySerializer
  has_one :requestor, serializer: UserSerializer

  delegate :state, to: :object

  def assistor
    UserSerializer.new(object.assistance.assistor).as_json if object.assistance&.assistor
  end

  def assistor_rating
    object.assistance&.feedback&.rating
  end

  def conference_link
    object.assistance&.conference_link
  end

  def assistance_start
    object.assistance&.start_at
  end
end
