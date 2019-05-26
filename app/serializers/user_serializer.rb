class UserSerializer < ActiveModel::Serializer

  include AvatarHelper

  format_keys :lower_camel
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
             :pronoun,
             :remote,
             :on_duty

  has_one :location, serializer: MyLocationSerializer
  has_one :cohort

  protected

  # Delegates to method in AvatarHelper
  def avatar_url
    self.avatar_for(object)
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
