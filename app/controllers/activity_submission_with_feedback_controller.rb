class ActivitySubmissionWithFeedbackController < ApplicationController

  # AJAX only
  # from activities#show
  def create
    @activity = Activity.find params[:activity_id]
    result = SubmitActivityWithFeedback.call(
      user: current_user,
      activity: @activity,
      activity_submission_with_optional_feedback: ActivitySubmissionWithOptionalFeedback.new(submission_params)
    )

    @success = result.success?

    if @success
      flash[:notice] = 'Congrats on completing this activity!'
      render nothing: true, status: 200
    else
      @errors = result.errors unless @success
      render layout: false, status: 400 # bad request
    end

  end

  private

  def submission_params
    params.require(:activity_submission_with_optional_feedback).permit(
      :time_spent,
      :note,
      :github_url,
      :detail,    # feedback
      :rating     # feedback
    )
  end

end