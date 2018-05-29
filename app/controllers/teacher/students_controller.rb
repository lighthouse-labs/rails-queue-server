class Teacher::StudentsController < Teacher::BaseController

  before_action :load_student, only: [:show]

  DEFAULT_PER = 10

  def index
    @students = Student.all
    filter_by_keywords
    flash[:alert] = @alert
  end

  def show
    @projects = Project.all
    @evaluations = @student.evaluations
    @assistances = @student.assistances.order(created_at: :desc).page(params[:page]).per(DEFAULT_PER)
  end

  private

  def load_student
    @student = Student.find(params[:id])
  end

  def filter_by_keywords
    if params[:keywords].present?
      students = @students.by_keywords(params[:keywords])
      @students = students.limit(10)
      if students.count > 10
        @alert = "More than 10 results. Consider narrowing down your query."
      end
    else
      @students = Student.limit(0)
    end
  end

end
