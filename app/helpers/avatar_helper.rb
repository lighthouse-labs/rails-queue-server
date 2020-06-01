module AvatarHelper

  def avatar_for(user)
    if user&.avatar_url
      user.avatar_url
    else
      image_path('duck-on.png')
    end
  end

end
