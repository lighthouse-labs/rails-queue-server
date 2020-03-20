class ActivityFeedbacksController < ApplicationController

  before_action :require_activity
  before_action :require_teacher

  respond_to :json

  def index
    @activity_feedbacks = @activity.activity_feedbacks.includes(:user).page(params[:page]).per(params[:limit] || 25)

    ratings = [:one, :two, :three, :four, :five].each_with_index.collect do |num, i|
      params[num] == 'true' ? i + 1 : nil
    end.compact

    @activity_feedbacks = @activity_feedbacks.where(rating: ratings) unless ratings.size == 5

    @activity_feedbacks = @activity_feedbacks.where(user_id: User.where(cohort: (Cohort.find(params[:cohort])))) if params[:cohort] != 'false'
    
    @activity_feedbacks = @activity_feedbacks.notable if params[:requireFeedback] == 'true'

    # render json: @activity_feedbacks
    respond_with @activity_feedbacks, meta: {
      currentPage: @activity_feedbacks.current_page,
      nextPage:    @activity_feedbacks.next_page,
      prevPage:    @activity_feedbacks.prev_page,
      totalPages:  @activity_feedbacks.total_pages,
      totalCount:  @activity_feedbacks.total_count
    }
  end

  # For barchart
  def rating_stats
    @activity_feedbacks = @activity.activity_feedbacks
    render json: @activity_feedbacks.rated.reorder(nil).group('ROUND(activity_feedbacks.rating)::integer').count
  end

  # For timeline chart
  def ratings_by_month
    @activity_feedbacks = @activity.activity_feedbacks
    data = @activity_feedbacks.rated.reorder(nil).group_by_month('activity_feedbacks.created_at').average(:rating)
    render json: data.select { |_, value| value > 0 }
  end

  private

  def require_teacher
    render json: { error: 'Not Authorized' }, status: :forbidden unless teacher? || admin?
  end

  def require_activity
    @activity = Activity.find params[:activity_id]
  end

end
