class AssistancePresenter < BasePresenter

  presents :assistance

  def avatar_for
    h.avatar_for(assistance.assistor)
  end

  def image_for_index_page
    h.image_tag(avatar_for, style: 'float:left; width:60px; margin-right: 8px; border-radius: 5px; border: 2px solid black')
  end

  def assistor_full_name
    if assistance.assistor.present?
      assistance.assistor.first_name + " " + assistance.assistor.last_name
    else
      'N/A'
    end
  end

  def email_info(teacher)
    if teacher.email?
      render(
        'shared/social_icon',
        handle:  teacher.email,
        company: 'github',
        url:     "https://github.com/#{teacher.email}"
      )
    end
  end

  def github_info(teacher)
    if teacher.github_username?
      render(
        'shared/social_icon',
        handle:  teacher.github_username,
        company: 'github',
        url:     "https://github.com/#{teacher.github_username}"
      )
    end
  end

  def twitter_info(teacher)
    if teacher.twitter?
      render(
        'shared/social_icon',
        handle:  teacher.twitter,
        company: 'twitter'
      )
    end
  end

  def slack_info(teacher)
    if teacher.slack?
      render(
        'shared/social_icon',
        handle:  teacher.slack,
        company: 'slack'
      )
    end
  end

  def skype_info(teacher)
    if teacher.skype?
      render(
        'shared/social_icon',
        handle:  teacher.skype,
        company: 'skype'
      )
    end
  end

  def formatted_date
    assistance.created_at.strftime('%B %d, %Y').to_s
  end

  def length
    distance_of_time_in_words(assistance.start_at, assistance.end_at).to_s
  end

end
