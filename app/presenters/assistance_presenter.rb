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
    render(
      'shared/social_icon',
      handle: teacher.email,
      company: 'github',
      url: "https://github.com/#{teacher.email}"
    ) if teacher.email?
  end

  def github_info(teacher)
    render(
      'shared/social_icon',
      handle: teacher.github_username,
      company: 'github',
      url: "https://github.com/#{teacher.github_username}"
    ) if teacher.github_username?
  end

  def twitter_info(teacher)
    render(
      'shared/social_icon',
      handle: teacher.twitter,
      company: 'twitter'
    ) if teacher.twitter?
  end

  def slack_info(teacher)
    render(
      'shared/social_icon',
      handle: teacher.slack,
      company: 'slack'
    ) if teacher.slack?
  end

  def skype_info(teacher)
    render(
      'shared/social_icon',
      handle: teacher.skype,
      company: 'skype'
    ) if teacher.skype?
  end

  def formatted_date
    "#{assistance.created_at.strftime('%B %d, %Y')}"
  end

  def length
    "#{distance_of_time_in_words(assistance.start_at, assistance.end_at)}"
  end
end
