class Admin::StudentsController < Admin::BaseController

  before_action :load_student, only: [:update, :edit, :destroy, :modal_content]
  before_action :prep_form, only: [:index, :edit]

  def index
    if params[:cohort_id]
      @current_cohort = Cohort.find(params[:cohort_id])
      @students = @current_cohort.students.order(first_name: :asc)
    else
      @students = Student.all
    end
  end

  def edit; end

  def update
    if @student.update(student_params)
      render nothing: true if request.xhr?
      redirect_to :back
    else
      prep_form
      render :edit
    end
  end

  def destroy
    @student.revert_to_prep
    redirect_to admin_students_path
  end

  def modal_content
    @cohorts = Cohort.active_or_upcoming
    # @mentors = Teacher.mentors(@student.cohort.location)
    render layout: false
  end

  def toggle_tech_interviews
    load_student
    @student.suppress_tech_interviews = !@student.suppress_tech_interviews
    @student.save
  end

  private

  def student_params
    params.require(:student).permit(
      :first_name,
      :last_name,
      :email,
      :github_username,
      :type,
      :unlocked_until_day,
      :mentor_id,
      :cohort_id
    )
  end

  def load_student
    @student = Student.find(params[:id])
  end

  def load_cohort
    @current_cohort = Cohort.find(params[:cohort_id])
  end

  def prep_form
    @cohorts = Cohort.is_active
  end

end
