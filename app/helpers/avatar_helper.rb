module AvatarHelper

  def avatar_for(user)
    if user&.custom_avatar?
      user.custom_avatar.url(:thumb)
    elsif user&.avatar_url
      user.avatar_url
    else
      image_path('duck-on.png')
    end
  end

end
