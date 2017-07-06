class Admin::AssistancesController < Admin::BaseController

  def index
    @assistances = Assistance.all.order(created_at: :desc)

    apply_filters

    @assist_length_avg = @assistances.completed.average_length
  end

  private

  def apply_filters
    filter_by_location
    filter_by_cohort
    filter_by_start_date
    filter_by_end_date
    filter_by_teacher
    filter_by_student_keywords
  end

  def filter_by_location
    @assistances = @assistances.joins(:cohort).where('cohorts.location_id' => params[:location]) if params[:location].present?
  end

  def filter_by_cohort
    @assistances = @assistances.where(cohort: params[:cohort_id]) if params[:cohort_id].present?
  end

  def filter_by_start_date
    params[:start_date] = Date.current.beginning_of_month.to_s unless params[:start_date].present?
    @assistances = @assistances.where("start_at > :date", date: params[:start_date])
  end

  def filter_by_end_date
    params[:end_date] = Date.current.end_of_month.to_s unless params[:end_date].present?
    end_datetime = Time.parse(params[:end_date]).end_of_day()
    @assistances = @assistances.where("start_at < :date", date: end_datetime)
  end

  def filter_by_teacher
    @assistances = @assistances.where(assistor: params[:teacher_id]) if params[:teacher_id].present?
  end

  def filter_by_student_keywords
    @assistances = @assistances.by_student_keywords(params[:keywords]) if params[:keywords].present?
  end
end
