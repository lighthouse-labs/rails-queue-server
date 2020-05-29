module AvatarHelper

  def avatar_for(user)
    if user&.custom_avatar?
      user.custom_avatar.try(:url, :thumb) || user.custom_avatar
    elsif user&.avatar_url
      user.avatar_url
    else
      image_path('duck-on.png')
    end
  end

end
