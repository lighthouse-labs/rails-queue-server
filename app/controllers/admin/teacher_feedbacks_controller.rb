class Admin::TeacherFeedbacksController < Admin::BaseController

  def index

    @feedbacks = Feedback.teacher_feedbacks

    apply_filters

    @feedbacks_csv = @feedbacks.completed
    @completed_feedbacks = @feedbacks_csv.group_by(&:teacher)

    respond_to do |format|
      format.html
      format.csv { render text: @feedbacks_csv.to_csv }
    end
  end

  private

  def apply_filters
    filter_by_start_date
    filter_by_end_date
    filter_by_teacher
  end

  def filter_by_start_date
    params[:start_date] = Date.current.beginning_of_month.to_s if params[:start_date].blank?
    start_datetime = Time.zone.parse(params[:start_date])
    @feedbacks = @feedbacks.where("updated_at > :date", date: start_datetime)
  end

  def filter_by_end_date
    params[:end_date] = Date.current.end_of_month.to_s if params[:end_date].blank?
    end_datetime = Time.zone.parse(params[:end_date]).end_of_day
    @feedbacks = @feedbacks.where("updated_at < :date", date: end_datetime)
  end

  def filter_by_teacher
    @feedbacks = @feedbacks.where("feedbacks.teacher_id = :teacher_id", teacher_id: params[:teacher_id]) if params[:teacher_id].present?
  end

  def safe_params
    params.except(:host, :port, :protocol).permit!
  end
  helper_method :safe_params

end
