class ActivitiesController < ApplicationController

  # must be before the course calendar inclusion now
  before_action :require_activity, only: [:show, :edit, :update]

  include CourseCalendar # concern

  before_action :teacher_required, only: [:new, :create, :edit, :update]
  before_action :check_if_day_unlocked, only: [:show]
  before_action :check_if_teacher_only, only: [:show]
  before_action :load_section, only: [:new, :edit, :update]
  before_action :load_form_url, only: [:new, :edit]

  def index
    @activities = Activity
    unless params[:term].blank?
      @activities = @activities.search(params[:term])
      @activities = @activities.where.not(day: nil)
    end

    @activities = @activities.active unless teacher? || admin?

    respond_to do |format|
      format.html
      format.js { render json: @activities, each_serializer: ActivitySerializer, root: false }
    end
  end

  def new
    @activity = Activity.new(day: params[:day_number])
    if @section
      @activity.section = @section
      @form_url = [@section, :activities]
    else
      @form_url = day_activities_path(params[:day_number])
    end
  end

  def create
    @activity = Activity.new(activity_params)
    if @activity.save(activity_params)
      handle_redirect("Activity Created!")
    else
      load_section
      load_new_url
      render :new
    end
  end

  def show
    # => If it evaluates code, we take multiple submissions (always a new submission)
    if @activity.evaluates_code?
      @activity_submission = ActivitySubmission.new
      @last_submission = current_user.activity_submissions.where(activity: @activity)
      @last_submission = @last_submission.where(cohort_id: current_user.cohort_id) if current_user.cohort_id? && @activity.bootcamp?
      @last_submission = @last_submission.last
    else
      @activity_submission = current_user.activity_submissions.where(activity: @activity).first || ActivitySubmission.new
    end

    @feedback = @activity.feedbacks.find_by(student: current_user)

    # new feedback model
    @activity_feedbacks = @activity.activity_feedbacks
    @activity_feedbacks = @activity_feedbacks.where(user: current_user) unless teacher?

    if teacher?
      @messages = @activity.messages
    elsif cohort # no messages if student or just User and no cohort is assigned
      @messages = @activity.messages.for_cohort(cohort)
    end
  end

  def update
    if @activity.update(activity_params)
      handle_redirect("Updated!")
    else
      render :edit
    end
  end

  def autocomplete
    @outcomes = (Outcome.search(params[:term]) - @activity.outcomes)
    render json: ActivityAutocompleteSerializer.new(outcomes: @outcomes).outcomes.as_json, root: false
  end

  private

  def activity_params
    params.require(:activity).permit(
      :name,
      :type,
      :duration,
      :start_time,
      :sequence,
      :instructions,
      :teacher_notes,
      :allow_submissions,
      :day,
      :section_id,
      :gist_url,
      :media_filename,
      :code_review_percent,
      :test_code,
      :initial_code
    )
  end

  def teacher_required
    redirect_to(day_activity_path(@activity.day, @activity), alert: 'Not allowed') unless teacher?
  end

  def require_activity
    if params[:uuid].present?
      @activity = Activity.find_by!(uuid: params[:uuid])
    else
      @activity = Activity.find(params[:id])
    end
    params[:day_number]          ||= @activity.day
    params[:teacher_resource_id] ||= @activity.section_id if @activity.teachers_only?
    params[:prep_id]             ||= @activity.section_id if @activity.prep?
    params[:project_id]          ||= @activity.section_id if @activity.project?
    # @activity = @activity.becomes(Activity)
  end

  def check_if_day_unlocked
    if student?
      redirect_to day_path('today'), alert: 'Not allowed' unless @activity.day == params[:day_number]
    end
  end

  def check_if_teacher_only
    if student? && @activity.teachers_only?
      redirect_to day_path('today'), alert: 'Students are not allowed to view teacher resoures'
    end
  end

  def load_section
    if slug = params[:prep_id]
      @section = Prep.find_by(slug: slug)
    elsif slug = params[:project_id]
      @section = Project.find_by(slug: slug)
    elsif slug = params[:teacher_resource_id] && (teacher? || admin?)
      @section = TeacherSection.find_by(slug: slug)
    end
  end

  def load_form_url
    if @activity
      load_edit_url
    else
      load_new_url
    end
  end

  def load_new_url
    @form_url = if params[:day_number]
      day_activities_path(params[:day_number])
    else
      [@section, :activities]
    end
  end

  def load_edit_url
    @form_url = if params[:day_number]
      day_activity_path(params[:day_number], @activity)
    elsif @section && @section.is_a?(Prep)
      prep_activity_path(@section, @activity)
    #elsif @section && @section.is_a?(Project)
      # project_activity_path <= Not yet supported - KV
    end
  end

  def handle_redirect(notice)
    if @activity.section
      # redirect_to polymorphic_url(@activity.section, @activity), notice: notice

      if @activity.prep?
        redirect_to prep_activity_path(@activity.section, @activity), notice: notice
      elsif @activity.project?
        redirect_to project_activity_path(@activity.section, @activity), notice: notice
      end
    else
      redirect_to day_activity_path(@activity.day, @activity), notice: notice
    end
  end
end
