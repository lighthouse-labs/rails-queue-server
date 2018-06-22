class LecturesController < ApplicationController

  include CourseCalendar

  before_action :retrieve_activity, except: [:index]
  before_action :teacher_required, only: [:edit, :update, :destroy, :new, :create]
  before_action :check_if_day_unlocked, only: [:show]

  def index
    @lectures = Lecture.all.most_recent_first
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

end
