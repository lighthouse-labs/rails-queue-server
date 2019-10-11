class ActivityAnswersController < ApplicationController

  before_action :require_activity

  def index
    @answers = @activity.answers.where(user: current_user)
    render json: @answers
  end

  def update
    @answer = @activity.answers.find_or_initialize_by(user: current_user, question_key: params[:id])
    @answer.update_state(params[:answer_text], params[:toggled] == 'true')
    render json: { success: true }
  end

  private

  def require_activity
    @activity = Activity.find_by!(uuid: params[:activity_id])
    # No real/actual need to restrict if user has access to activity.
  end

end
