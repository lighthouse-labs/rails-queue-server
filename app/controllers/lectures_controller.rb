class LecturesController < ApplicationController

  include CourseCalendar

  before_action :retrieve_activity
  before_action :teacher_required, only: [:edit, :update, :destroy, :new, :create]
  before_action :check_if_day_unlocked, only: [:show]

  def show
    @lecture = Lecture.find(params[:id])
  end

  def new
    @lecture = if params[:activity_id]
                 Activity.find(params[:activity_id]).lectures.new
               else
                 Lecture.new
               end
    @lecture.cohort = @cohort
  end

  def create

    lecture_complete = Lecture::Complete.call(
      activity: @activity,
      lecture_params: lecture_params,
      presenter: User.find(lecture_params[:presenter_id])
    )

    if lecture_complete.success?
      redirect_to activity_lecture_path(@activity, @lecture), notice: 'Created! Students notified via e-mail.'
    else
      render :new # edit
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
      :presenter_name,
      :body,
      :teacher_notes,
      :youtube_url
    )
  end

end