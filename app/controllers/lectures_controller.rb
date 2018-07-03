class LecturesController < ApplicationController

  include CourseCalendar

  before_action :retrieve_activity, except: [:index]
  before_action :require_lecture, only: [:edit, :update, :destroy, :show]
  before_action :teacher_required, only: [:edit, :update, :destroy, :new, :create]
  before_action :check_if_day_unlocked, only: [:show]

  DEFAULT_PER = 20

  def index
    @lectures = Lecture.all.most_recent_first
    if current_user && teacher?
      @lectures = @lectures.for_teacher(current_user)
    elsif current_user && active_student?
      @lectures = @lectures.for_cohort(current_user.cohort)
    end
    apply_filters
    @count = @lectures.count
    @lectures = @lectures.page(params[:page]).per(DEFAULT_PER)
  end

  def show
  end

  def new
    @lecture = Lecture.new(
      presenter: current_user,
      cohort:    @cohort,
      subject: @activity.name
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
      render :new
    end
  end

  def edit
    @lecture = @activity.lectures.find(params[:id])
  end

  def update
    if @lecture.update(lecture_params)
      redirect_to activity_lecture_path(@activity, @lecture), notice: 'Updated!'
    else
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
      redirect_to day_path('today'), alert: 'Not allowed' unless @activity.day == params[:day_number]
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
    filter_by_lecture_scope
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

  def filter_by_lecture_scope
    if params[:all_lectures].present?
      @lectures = Lecture.all.most_recent_first
    elsif params[:my_cohort].present?
      @lectures = @lectures.for_cohort(current_user.cohort)
    elsif params[:my_lectures].present?
      @lectures = @lectures.for_teacher(current_user)
    end
  end

  def filter_by_location
    @lectures = @lectures.filter_by_presenter_location(params[:location]) if params[:location].present?
  end

  def filter_by_day
    @lectures = @lectures.where(day: params[:day]) if params[:day].present?
  end

  def filter_by_presenter
    @lectures = @lectures.where(presenter: params[:teacher_id]) if params[:teacher_id].present?
  end

  def filter_by_keywords
    @lectures = @lectures.by_keywords(params[:keywords]) if params[:keywords].present?
  end

  def filter_by_advanced_topics
    @lectures = @lectures.advanced_topics if params[:advanced].present?
  end

  def filter_by_start_date
    @lectures = @lectures.where("lectures.created_at > :date", date: params[:start_date]) if params[:start_date].present?
  end

  def filter_by_end_date
    params[:end_date] = Date.current.end_of_month.to_s if params[:end_date].blank?
    end_datetime = Time.zone.parse(params[:end_date]).end_of_day
    @lectures = @lectures.where("lectures.created_at < :date", date: end_datetime)
  end

  def filter_by_video
    @lectures = @lectures.where.not(youtube_url: nil) if params[:video].present?
  end

  def filter_by_unlocked_days
    @lecture_days = [ "w01d1", "w01d2", "w01d3", "w01d4", "w01d5", 
                      "w02d1", "w02d2", "w02d3", "w02d4", "w02d5", 
                      "w03d1", "w03d2", "w03d3", "w03d4", "w03d5", 
                      "w04d1", "w04d2", "w04d3", "w04d4", "w04d5", 
                      "w05d1", "w05d2", "w05d3", "w05d4", "w05d5", 
                      "w06d1", "w06d2", "w06d3", "w06d4", "w06d5", 
                      "w07d1", "w07d2", "w07d3", "w07d4", "w07d5", 
                      "w08d1", "w08d2", "w08d3", "w08d4", "w08d5", 
                      "w09d1", "w09d2", "w09d3", "w09d4", "w09d5", 
                      "w10d1", "w10d2", "w10d3", "w10d4", "w10d5" ]

    if current_user && active_student?
      this_day = CurriculumDay.new(Date.current, current_user.cohort).to_s
      # go to Friday to show lectures whose days are unlocked
      this_day[4] = "5"
      # select the lectures given on days that are before or during this week
      days = @lecture_days.select { |d| @lecture_days.index(d) <= @lecture_days.index(this_day) }
      @lectures = @lectures.where(day: days)
    end
  end

end
