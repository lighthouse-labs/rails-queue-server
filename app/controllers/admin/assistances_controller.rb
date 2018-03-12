class Admin::AssistancesController < Admin::BaseController

  DEFAULT_PER = 100

  def index
    @assistances = Assistance.order(created_at: :desc)

    apply_filters

    @assist_length_avg = @assistances.completed.average_length
    @avg_l_score = @assistances.where.not(rating: nil).average(:rating).to_f.round(1)
    @distinct_students = @assistances.pluck(:assistee_id).uniq.count
    @distinct_teachers = @assistances.pluck(:assistor_id).uniq.count
    @assistance_count = @assistances.count
    @average_time_in_queue = average_time_in_queue(@assistances)

    @assistances = @assistances.page(params[:page]).per(DEFAULT_PER)
  end

  private

  def apply_filters
    filter_by_location
    filter_by_cohort
    filter_by_start_date
    filter_by_end_date
    filter_by_day
    filter_by_teacher
    filter_by_student_keywords
    filter_by_flagged
  end

  def filter_by_location
    @assistances = @assistances.joins(:assistee).where('users.location_id' => params[:location]) if params[:location].present?
  end

  def filter_by_cohort
    @assistances = @assistances.where(cohort: params[:cohort_id]) if params[:cohort_id].present?
  end

  def filter_by_start_date
    @assistances = @assistances.where("start_at > :date", date: params[:start_date]) if params[:start_date].present?
  end

  def filter_by_end_date
    params[:end_date] = Date.current.end_of_month.to_s if params[:end_date].blank?
    end_datetime = Time.zone.parse(params[:end_date]).end_of_day
    @assistances = @assistances.where("start_at < :date", date: end_datetime)
  end

  def filter_by_day
    @assistances = @assistances.where(day: params[:day]) if params[:day].present?
  end

  def filter_by_teacher
    @assistances = @assistances.where(assistor: params[:teacher_id]) if params[:teacher_id].present?
  end

  def filter_by_student_keywords
    @assistances = @assistances.by_student_keywords(params[:keywords]) if params[:keywords].present?
  end

  def filter_by_flagged
    @assistances = @assistances.where(flag: true) if params[:flagged].present?
  end

  def average_time_in_queue(assistances)
    # Don't count ARs < 1 second
    # They are generated ARs when a teacher registers an assistance without student being in queue
    time_in_queue_arr = assistances.map{ |a| AssistanceRequest.find_by(assistance_id: a).time_in_queue }.select{ |tiq| tiq > 1 } 
    return 0 if time_in_queue_arr.empty? 
    (time_in_queue_arr.sum.to_f / time_in_queue_arr.size).floor
  end

end
