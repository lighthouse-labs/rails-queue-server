class Admin::TeacherFeedbacksController < Admin::BaseController

  FILTER_BY_OPTIONS = [:teacher_id, :teacher_location_id, :start_date, :end_date].freeze

  def index
    params[:teacher_location_id] ||= current_user.location.id.to_s
    params[:start_date] ||= Date.current.beginning_of_month.to_s
    params[:end_date] ||= Date.current.end_of_month.to_s

    @feedbacks = Feedback.teacher_feedbacks.filter_by(filter_by_params)
    @feedbacks_csv = @feedbacks.completed
    @completed_feedbacks = @feedbacks_csv.group_by(&:teacher)

    respond_to do |format|
      format.html
      format.csv { render text: @feedbacks_csv.to_csv }
    end
  end

  private

  def safe_params
    params.except(:host, :port, :protocol).permit!
  end
  helper_method :safe_params

  def filter_by_params
    params.slice(*FILTER_BY_OPTIONS).select { |_k, v| v.present? }
  end

end
