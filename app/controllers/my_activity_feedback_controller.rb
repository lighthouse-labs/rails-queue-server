class MyActivityFeedbackController < ApplicationController

  before_action :require_activity

  # XHR only (JSON response)
  def update
    # We used to allow multiple feedback records per student. Now we only allow one :)
    @activity_feedback = @activity.activity_feedbacks.filter_by_user(current_user).reverse_chronological_order.first

    @activity_feedback ||= @activity.activity_feedbacks.new(user: current_user)

    @activity_feedback.rating = params[:rating] unless params[:rating].nil?
    @activity_feedback.detail = params[:detail] unless params[:detail].nil?

    if @activity_feedback.save
      render json: {
        success:          true,
        activityFeedback: ActivityFeedbackSerializer.new(@activity_feedback)
      }
    else
      render json: {
        success: false,
        error:   @activity_feedback.errors.full_messages.first
      }
    end
  end

  private

  def require_activity
    @activity = Activity.find params[:activity_id]
  end

end
