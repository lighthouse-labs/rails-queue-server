class UserSerializer < ActiveModel::Serializer

  root false

  attributes :id,
             :type,
             :email,
             :first_name,
             :last_name,
             :full_name,
             :github_username,
             :avatar_url,
             :busy,
             :last_assisted_at,
             :remote

  has_one :location
  has_one :cohort

  protected

  def avatar_url
    object.custom_avatar.try(:url, :thumb) || object.avatar_url
  end

  def busy
    object.busy? if teacher?
  end

  def remote
    !teacher? && (object.cohort.try(:location) != object.location)
  end

  def teacher?
    object.is_a?(Teacher)
  end

end
