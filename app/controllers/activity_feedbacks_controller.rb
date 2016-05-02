class ActivityFeedbacksController < ApplicationController

  # assume xhr only
  def create
    @activity = Activity.find params[:activity_id]

    @activity_feedback = @activity.activity_feedbacks.new(feedback_params)
    @activity_feedback.user = current_user

    if @activity_feedback.save
      render partial: 'activity_feedback', locals: { activity_feedback: @activity_feedback } 
    else
      render text: "Failed: #{@activity_feedback.errors.full_messages.first}", status: 502
    end
  end

  private

  def feedback_params
    params.require(:activity_feedback).permit(:detail, :sentiment, :rating)
  end

end
