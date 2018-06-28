class LecturesController < ApplicationController

  include CourseCalendar

  before_action :retrieve_activity, except: [:index]
  before_action :teacher_required, only: [:edit, :update, :destroy, :new, :create]
  before_action :check_if_day_unlocked, only: [:show]

  DEFAULT_PER = 20

  def index
    @lectures = Lecture.all.most_recent_first
    if current_user && teacher?
      @lectures = @lectures.for_teacher(current_user)
    elsif current_user && student?
      @lectures = @lectures.for_cohort(current_user.cohort)
    end
    apply_filters
    @count = @lectures.count
    @lectures = @lectures.page(params[:page]).per(DEFAULT_PER)
  end

  def show
    @lecture = Lecture.find(params[:id])
    @activity = Activity.find(@lecture.activity_id)
  end

  def new
    @lecture = Lecture.new(
      presenter: current_user,
      cohort:    @cohort
    )
    @lecture.activity = Activity.find(params[:activity_id]) if params[:activity_id].present?
  end

  def create
    @lecture = Lecture::Complete.call(
      activity:       @activity,
      lecture_params: lecture_params,
      presenter:      Teacher.find(lecture_params[:presenter_id])
    )

    if @lecture.success?
      redirect_to activity_lecture_path(@activity, @lecture.lecture), notice: 'Created! Students notified via e-mail.'
    else
      render :edit
    end
  end

  def edit
    @lecture = Lecture.find(params[:id])
    @activity = Activity.find(params[:activity_id])
  end

  def update
    @lecture = Lecture.find(params[:id])
    @activity = Activity.find(params[:activity_id])
    if @lecture.update(lecture_params)
      redirect_to activity_lecture_path(@activity, @lecture), notice: 'Updated!'
    else
      render :edit
    end
  end

  def destroy
    @lecture = Lecture.find(params[:id])
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
    # filter_by_unlocked_days
  end

  def filter_by_location
    @lectures = @lectures.filter_by_presenter_location(params[:location]) if params[:location].present?
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

  def filter_by_unlocked_days
  end

  def filter_by_advanced_topics
    @lectures = @lectures.advanced_topics if params[:advanced].present?
  end

  def filter_by_start_date
    @lectures = @lectures.where("created_at > :date", date: params[:start_date]) if params[:start_date].present?
  end

  def filter_by_end_date
    params[:end_date] = Date.current.end_of_month.to_s if params[:end_date].blank?
    end_datetime = Time.zone.parse(params[:end_date]).end_of_day
    @lectures = @lectures.where("created_at < :date", date: end_datetime)
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

end
