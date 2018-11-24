class QueueStudentSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :first_name, :last_name, :avatar_url, :github_username

end
