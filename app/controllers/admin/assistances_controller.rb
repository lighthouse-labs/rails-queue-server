class Admin::AssistancesController < Admin::BaseController

  def index
    @assistances = Assistance.all.order(created_at: :desc)
    params[:start_date] = Date.current.beginning_of_month.to_s unless params[:start_date].present?
    params[:end_date] = Date.current.end_of_month.to_s unless params[:end_date].present?

    apply_filters

    # Average time it takes to complete and assistance request
    # There has got to be a better way to do this
    @length_arr = @assistances.completed.collect{|s| s.end_at - s.start_at}
    @assist_length_avg = @length_arr.inject{ |sum, el| sum + el }.to_f / @length_arr.size / 60
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
    if params[:location].present?
      @assistances = @assistances.joins(:cohort).where('cohorts.location_id' => params[:location])
    end
  end

  def filter_by_cohort
    if params[:cohort_id].present?
      @assistances = @assistances.where(cohort: params[:cohort_id])
    end
  end

  def filter_by_start_date
    @assistances = @assistances.where("start_at > :date", date: params[:start_date])
  end

  def filter_by_end_date
    end_datetime = Time.parse(params[:end_date]).end_of_day()
    @assistances = @assistances.where("start_at < :date", date: end_datetime)
  end

  def filter_by_teacher
    if params[:teacher_id].present?
      @assistances = @assistances.where(assistor: params[:teacher_id])
    end
  end

  def filter_by_student_keywords
    if params[:keywords].present?
      @assistances = @assistances.by_student_keywords(params[:keywords])
    end
  end

end
