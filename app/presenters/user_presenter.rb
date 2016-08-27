class UserPresenter < BasePresenter
  presents :user

  delegate :full_name, :email, :phone_number, :quirky_fact, :bio, :specialties, :company_name, :company_url, :slack, :skype, :type, to: :user

  def image_for_index_page
    h.image_tag(avatar_for, style: 'float:left; width:60px; margin-right: 8px; border-radius: 5px; border: 2px solid black')
  end

  def image_for_show_page
    h.image_tag(avatar_for, size: '200x200')
  end

  def github_info
    render(
      'shared/social_icon',
      handle: user.github_username,
      company: 'github',
      url: "https://github.com/#{user.github_username}"
    ) if user.github_username?
  end

  def twitter_info
    render(
      'shared/social_icon',
      handle: user.twitter,
      company: 'twitter',
      url: "https://twitter.com/#{user.twitter}"
    ) if user.twitter?
  end

  def slack_info
    render(
      'shared/social_icon',
      handle: user.slack,
      company: 'slack'
    ) if user.slack?
  end

  def skype_info
    render(
      'shared/social_icon',
      handle: user.skype,
      company: 'skype'
    ) if user.skype?
  end

  def email_info
    render(
      'shared/social_icon',
      handle: user.email,
      company: 'inbox',
      url: "mailto:#{user.email}"
    ) if user.email?
  end

  private

  def avatar_for
    if user.custom_avatar.url
      user.custom_avatar.url(:thumb)
    else
      user.avatar_url
    end
  end

end