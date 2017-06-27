class CodeReviewsController < ApplicationController

  include CourseCalendar

  before_action :teacher_required
  before_action :load_cohorts
  # before_filter :load_student

  def index; end

  def show
    @code_review = Assistance.find(params[:id])
    render :show_modal, layout: false
  end

  def new
    @student = Student.active.find params[:student_id]
    @assistance = Assistance.new(assistor: current_user, assistee: @student)

    @activities = {
      'Submitted'     => @student.submitted_but_not_reviewed_activities,
      'Not Submitted' => @student.unsubmitted_activities_before(today),
      'Reviewed'      => @student.code_reviewed_activities
    }

    render :new_modal, layout: false
  end

  def create
    code_review_request = CodeReviewRequest.new(
      requestor_id: params[:assistance][:assistee_id],
      activity_id:  params[:activity_id]
    )

    code_review_request.save!
    code_review_request.start_assistance(current_user)
    code_review = code_review_request.reload.assistance
    code_review.end(params[:assistance][:notes], params[:assistance][:rating].to_i, params[:assistance][:student_notes])

    redirect_to :back
  end

  private

  def teacher_required
    redirect_to(:root, alert: 'Not allowed') unless teacher?
  end

  def load_cohorts
    # branch mentors see their respective satellite locations' CRs too!
    # for satellite mentors, use their parent (branch) location
    location = current_user.location
    if branch_location = current_user.location.supported_by_location
      location = branch_location
    end

    @cohorts = Cohort.is_active.chronological.where(location: location)
    if params[:cohort_id].present?
      cohort = Cohort.find params[:cohort_id]
      @cohorts.push cohort
    end
    @cohorts = @cohorts.uniq
    @cohorts
  end

  def load_student
    id = params["student_id"] || params["assistee-id"]
    puts "the id is: #{id}"
    @student = Student.find(id)
  end

end
