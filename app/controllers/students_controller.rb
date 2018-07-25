class StudentsController < Teacher::BaseController

  before_action :disallow_unless_enrolled
  before_action :teacher_required, only: [:show, :new_code_review_modal]
  before_action :load_student, only: [:show, :new_code_review_modal]

  before_action :load_cohort
  before_action :restrict_for_limited_cohort

  def index
    @students = @cohort.students.active.order(location_id: :asc, first_name: :asc)
  end

  private

  def disallow_unless_enrolled
    redirect_to(:root, alert: 'Not allowed') unless current_user && cohort && (student? || teacher?)
  end

  def teacher_required
    redirect_to(:root, alert: 'Not allowed') unless teacher?
  end

  def load_student
    @student = Student.find(params[:id])
  end

  # "limited" cohorts is a pretty special case for giving curriculum access to previous alumni
  # since it will contain ALL previous alumni from that location/branch, then this list will be too large
  # disallow teachres and studenst alike to view this list.
  #  - KV Aug 29, 2016
  def restrict_for_limited_cohort
    redirect_to(:root, alert: 'Not allowed') if @cohort&.limited?
  end

  def load_cohort
    @cohort = if teacher?
                cohort_id = params[:cohort_id].presence || cohort
                Cohort.find(cohort_id)
              else
                current_user.cohort
              end
  end

end
