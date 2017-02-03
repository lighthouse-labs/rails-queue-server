class Admin::CurriculumFeedbacksController < Admin::BaseController

  FILTER_BY_OPTIONS = [:program, :user_id, :user_location_id, :cohort_id, :start_date, :end_date, :day, :type].freeze
  DEFAULT_PER = 10

  def index
    @feedbacks = ActivityFeedback.filter_by(filter_by_params).reorder(order)
    @rating = @feedbacks.average_rating
    @paginated_feedbacks = @feedbacks.page(params[:page]).per(DEFAULT_PER)

    @monthly_chart_data = @feedbacks.reorder('').group_by_month('activity_feedbacks.created_at', format: "%b %Y").average(:rating)

    respond_to do |format|
      format.html
      format.csv {render text: @feedbacks.to_csv}
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
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def order
    sort_column + ' ' + sort_direction
  end

  def safe_params
    params.except(:host, :port, :protocol).permit!
  end
  helper_method :safe_params

  def filter_by_params
    params.slice(*FILTER_BY_OPTIONS).select { |k,v| v.present? }
  end
end
