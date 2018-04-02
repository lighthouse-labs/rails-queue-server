class Admin::StudentsController < Admin::BaseController

  before_action :load_student, only: [:update, :edit, :destroy, :modal_content, :toggle_tech_interviews]
  before_action :prep_form, only: [:index, :edit]

  DEFAULT_PER = 50

  def index
    if params[:cohort_id]
      @current_cohort = Cohort.find(params[:cohort_id])
      @students = @current_cohort.students.order(first_name: :asc).page(params[:page]).per(DEFAULT_PER)
      @student_count = @current_cohort.students.count
    else
      @students = Student.all.page(params[:page]).per(DEFAULT_PER)
      @student_count = Student.count
    end
  end

  def edit; end

  def update
    if @student.update(student_params)
      prep_form
      flash[:notice] = "#{@student.full_name} Updated"
      redirect_to admin_students_path
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
    @student.suppress_tech_interviews = !@student.suppress_tech_interviews
    if @student.save
      render json: { status: "Success" }
    else
      render json: { status: 500, errors: @student.errors.full_messages }
    end
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
