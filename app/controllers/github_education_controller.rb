class GithubEducationController < ApplicationController

  layout 'auth'

  before_action :require_student_or_alumni

  def show
  end

  private

  def require_student_or_alumni
    redirect_to(:root, alert: 'Not allowed') unless current_user.is_a?(Teacher) || current_user&.active_student? || current_user&.alumni?
  end

end
