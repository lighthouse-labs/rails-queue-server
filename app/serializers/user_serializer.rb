class UserSerializer < ActiveModel::Serializer

  # for #avatar_url to work, since it assumes image_path will work
  include ActionView::Helpers::AssetTagHelper
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
             :on_duty,
             :waiting_for_assistance?,
             :being_assisted?,
             :current_assistance_conference,
             :current_assistor,
             :position_in_queue,
             :admin

  has_one :location, serializer: MyLocationSerializer
  has_one :cohort

  protected

  # Delegates to method in AvatarHelper
  def avatar_url
    avatar_for(object)
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
