class UserPresenter < BasePresenter

  presents :user

  delegate :full_name, :email, :phone_number, :quirky_fact, :bio, :specialties, :company_name, :company_url, :slack, :skype, :type, to: :user

  def image_for_index_page
    h.image_tag(avatar_for, style: 'float:left; width:60px; margin-right: 8px; border-radius: 5px; border: 2px solid black; overflow: hidden;')
  end

  def image_for_show_page
    h.image_tag(avatar_for, size: '200x200')
  end

  def github_info
    if user.github_username?
      render(
        'shared/social_icon',
        handle:  user.github_username,
        company: 'github',
        url:     "https://github.com/#{user.github_username}"
      )
    end
  end

  def twitter_info
    if user.twitter?
      render(
        'shared/social_icon',
        handle:  user.twitter,
        company: 'twitter',
        url:     "https://twitter.com/#{user.twitter}"
      )
    end
  end

  def slack_info
    if user.slack?
      render(
        'shared/social_icon',
        handle:  user.slack,
        company: 'slack'
      )
    end
  end

  def skype_info
    if user.skype?
      render(
        'shared/social_icon',
        handle:  user.skype,
        company: 'skype'
      )
    end
  end

  def email_info
    if user.email?
      render(
        'shared/social_icon',
        handle:  user.email,
        company: 'inbox',
        url:     "mailto:#{user.email}"
      )
    end
  end

  def user_info
    if user.type == 'Student'
      render('shared/student_info', student: user, show_email: true)
    elsif user.type == 'Teacher'
      output = link_to image_for_index_page, teacher_path(user)
      output += link_to user.full_name.to_s, teacher_path(user)
      user_content output
    else
      output = image_for_index_page
      output += user.full_name.to_s
      user_content output
    end
  end

  private

  def avatar_for
    h.avatar_for(user)
  end

  def user_content(output)
    output += tag 'br'
    output += mail_to user.email, user.email, target: '_blank', class: 'email'
    output += tag 'br'
    output += content_tag :span, user.location.name, class: 'badge badge-primary' if user.location
    content_tag :div, output
  end

end
