module GithubEducationPack

  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_github_edu_pack,
                  if:   :eligible_for_github_edu_pack?,
                  only: [:show]
  end

  private

  def redirect_to_github_edu_pack
    redirect_to github_education_path
  end

  def eligible_for_github_edu_pack?
    ENV['GITHUB_EDUCATION_SCHOOL_ID'].present? &&
      ENV['GITHUB_EDUCATION_SECRET_KEY'].present? &&
      current_user&.eligible_for_github_education_pack? &&
      !current_user.github_education_pack_actioned)
  end

end
