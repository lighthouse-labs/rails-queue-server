class LecturesController < ApplicationController

  include CourseCalendar

  before_action :retrieve_activity, except: [:index]
  before_action :require_lecture, only: [:edit, :update, :destroy, :show]
  before_action :teacher_required, only: [:edit, :update, :destroy, :new, :create]
  before_action :check_if_day_unlocked, only: [:show]

  DEFAULT_PER = 20

  def index
    @lectures = Lecture.all.most_recent_first
    apply_filters
    @lectures = @lectures.page(params[:page]).per(DEFAULT_PER)
  end

  def show
    load_day_schedule
  end

  def new
    load_day_schedule
    @lecture = Lecture.new(
      presenter: current_user,
      cohort:    @cohort,
      subject:   @activity.name
    )
  end

  def create
    @teacher = Teacher.find(lecture_params[:presenter_id]) if lecture_params[:presenter_id].present?
    result = Lecture::Complete.call(
      activity:       @activity,
      lecture_params: lecture_params,
      presenter:      @teacher
    )
    @lecture = result.lecture

    if result.success?
      redirect_to activity_lecture_path(@activity, @lecture), notice: "Created! #{@cohort.name} students notified via e-mail."
    else
      load_day_schedule
      render :new
    end
  end

  def edit
    load_day_schedule
    @lecture = @activity.lectures.find(params[:id])
  end

  def update
    if @lecture.update(lecture_params)
      redirect_to activity_lecture_path(@activity, @lecture), notice: 'Updated!'
    else
      load_day_schedule
      render :edit
    end
  end

  def destroy
    path = activity_path(@activity)
    if @lecture.destroy
      redirect_to path, notice: 'Lecture deleted'
    else
      redirect_to path, alert: 'Unable to delete lecture'
    end
  end

  private

  def retrieve_activity
    @activity = Activity.find(params[:activity_id])
  end

  def require_lecture
    @lecture = @activity.lectures.find(params[:id])
  end

  def teacher_required
    redirect_to activity_lecture_path unless teacher?
  end

  def check_if_day_unlocked
    if student?
      redirect_to day_path('today'), alert: 'Not allowed' unless current_user.can_access_day?(@activity.day)
    end
  end

  def lecture_params
    params.require(:lecture).permit(
      :presenter_id,
      :cohort_id,
      :activity_id,
      :day,
      :subject,
      :body,
      :teacher_notes,
      :youtube_url
    )
  end

  def apply_filters
    filter_by_student_cohort
    filter_by_location
    filter_by_day
    filter_by_presenter
    filter_by_keywords
    filter_by_advanced_topics
    filter_by_start_date
    filter_by_end_date
    filter_by_video
    filter_by_unlocked_days
  end

  def filter_by_student_cohort
    if student? && cohort
      params[:cohort] ||= 'my'
      @lectures = @lectures.for_cohort(cohort) if params[:cohort] == 'my'
    end
  end

  def filter_by_location
    @lectures = @lectures.filter_by_presenter_location(params[:location]) if params[:location].present?
  end

  def filter_by_day
    @lectures = @lectures.where(day: params[:day].to_s.downcase) if params[:day].present?
  end

  def filter_by_presenter
    @lectures = @lectures.where(presenter: params[:teacher_id]) if params[:teacher_id].present?
  end

  def filter_by_keywords
    @lectures = @lectures.by_keywords(params[:keywords]) if params[:keywords].present?
  end

  def filter_by_advanced_topics
    @lectures = @lectures.advanced_topics if @program.has_advanced_lectures? && params[:advanced_topics].present?
  end

  def filter_by_start_date
    if params[:start_date].present?
      start_datetime = Time.zone.parse(params[:start_date]).beginning_of_day
      @lectures = @lectures.where("lectures.created_at >= :date", date: start_datetime)
    end
  end

  def filter_by_end_date
    if params[:end_date].present?
      end_datetime = Time.zone.parse(params[:end_date]).end_of_day
      @lectures = @lectures.where("lectures.created_at <= :date", date: end_datetime)
    end
  end

  def filter_by_video
    @lectures = @lectures.with_video if params[:video].present?
  end

  def filter_by_unlocked_days
    @lectures = @lectures.until_day(current_user.curriculum_day) if active_student?
  end

end
