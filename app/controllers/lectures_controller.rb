class LecturesController < ApplicationController

  include CourseCalendar

  before_action :require_activity
  before_action :require_lecture, only: [:edit, :update, :destroy, :show]
  before_action :teacher_required, only: [:edit, :update, :destroy, :new, :create]
  before_action :check_if_day_unlocked, only: [:show]

  def show; end

  def new
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

  def require_activity
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
      redirect_to day_path('today'), alert: 'Not allowed' unless @activity.id.to_s == params[:activity_id]
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
