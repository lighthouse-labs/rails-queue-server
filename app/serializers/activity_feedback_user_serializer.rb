class ActivityFeedbackUserSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :first_name, :last_name, :type, :avatar_url

end
