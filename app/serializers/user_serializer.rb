class UserSerializer < ActiveModel::Serializer

  # for #avatar_url to work, since it assumes image_path will work
  include ActionView::Helpers::AssetTagHelper
  include AvatarHelper

  format_keys :lower_camel
  root false

  attributes :uid,
             :full_name,
             :pronoun,
             :avatar_url,
             :socials,
             :info,
             :info_url,
             :on_duty,
             :busy?,
             :first_name,
             :access

  protected

  # Delegates to method in AvatarHelper
  def avatar_url
    avatar_for(object)
  end

  def socials
    socials = {}
    socials['github'] = object.github_username if object.github_username?
    socials['email'] = object.email if object.email?
    socials['slack'] = object.slack if object.slack?
    socials
  end

  def info
    info = {}
    # wan't to limit queries to shards
    # info['location'] = object.location.name if object.location
    # info['week'] = object.cohort.week if object.cohort&.week
    info
  end

  def info_url
    # when mentors are moved to queue db this should link to a mentor profile page.
  end

  def access
    access = []
    access.push('student') if object.is_a?(Student)
    access.push('teacher') if object.is_a?(Teacher)
    access.push('admin') if object.admin?
    access.push('super-admin') if object.super_admin?
  end

end
