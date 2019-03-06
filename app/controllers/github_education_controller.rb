class GithubEducationController < ApplicationController

  # layout 'auth'

  before_action :require_eligible_user

  def show
  end

  # PUT
  def claim
    result = ClaimGithubEducationPack.call(user: current_user)
    if result.success?
      redirect_to result.url
    else
      # If user.save failed, probably due to incomplete user profile (odd, I know) - KV
      redirect_to edit_profile_path, alert: result.error
    end
  end

  # PUT
  def skip
    unless current_user.github_education_pack_actioned?
      current_user.github_education_action = 'skipped'
      current_user.github_education_action_at = Time.current
      current_user.save(validate: false)
      flash[:notice] = "You've chosen to skip GitHub Education. Check your Profile page if you still want it later."
    end
    redirect_to params[:original_destination] || day_path('today')
  end

  private

  def require_eligible_user
    redirect_to(:root, alert: 'Sorry, access not allowed') unless current_user&.eligible_for_github_education_pack?
  end

end
