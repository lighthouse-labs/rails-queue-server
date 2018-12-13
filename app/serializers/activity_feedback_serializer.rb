class ActivityFeedbackSerializer < ActiveModel::Serializer

  format_keys :lower_camel
  attributes :id, :rating, :detail, :created_at

  has_one :user, serializer: ActivityFeedbackUserSerializer

end
