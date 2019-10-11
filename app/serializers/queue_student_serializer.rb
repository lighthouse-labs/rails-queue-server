class QueueStudentSerializer < ActiveModel::Serializer

  include AvatarHelper

  format_keys :lower_camel

  attributes :id,
             :first_name,
             :last_name,
             :avatar_url,
             :github_username,
             :last_assisted_at,
             :pronoun

  has_one :cohort

  # Delegates to method in AvatarHelper
  def avatar_url
    avatar_for(object)
  end

end
