class Admin::CurriculumFeedbacksController < Admin::BaseController

  FILTER_BY_OPTIONS = [:program, :user_id, :user_location_id, :cohort_id, :start_date, :end_date, :day, :type, :ratings, :legacy].freeze
  DEFAULT_PER = 10

  def index
    @feedbacks = ActivityFeedback.filter_by(filter_by_params).reorder(order)
    @ratings = params[:ratings]
    @avg_rating = @feedbacks.average_rating
    @paginated_feedbacks = @feedbacks.page(params[:page]).per(DEFAULT_PER)

    if params[:charts] == 'Enable'
      @monthly_chart_data = @feedbacks.reorder('').group_by_month('activity_feedbacks.created_at', format: "%b %Y").average(:rating)

      if params[:type] == 'Bootcamp'
        @bootcamp_data_by_curriculum_day = @feedbacks.reorder('activities.day ASC').references(:activity).group('activities.day').average(:rating)
        # raise @bootcamp_data_by_curriculum_day.inspect
      end
    end

    respond_to do |format|
      format.html
      format.csv { render text: @feedbacks.to_csv }
      format.xls do
        headers['Content-Disposition'] = 'attachment; filename=curriculum_feedbacks.xls'
      end
    end
  end

  private

  def sort_column
    ["rating", "activity_feedbacks.created_at"].include?(params[:sort]) ? params[:sort] : "activity_feedbacks.created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def order
    sort_column + ' ' + sort_direction
  end

  def safe_params
    params.except(:host, :port, :protocol).permit!
  end
  helper_method :safe_params

  def filter_by_params
    params.slice(*FILTER_BY_OPTIONS).select { |_k, v| v.present? }
  end

end
