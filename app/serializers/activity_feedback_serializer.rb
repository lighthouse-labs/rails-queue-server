class ActivityFeedbackSerializer < ActiveModel::Serializer

  format_keys :lower_camel
  root false

  attributes :id, :rating, :detail, :created_at

  has_one :user, serializer: ActivityFeedbackUserSerializer

  def rating
    object.rating.round if object.rating?
  end

end
