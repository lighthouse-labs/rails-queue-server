class Teacher::StudentsController < Teacher::BaseController

  before_action :load_student, only: [:show]

  def index; end

  def show
    @projects = Project.all
    @evaluations = Evaluation.where(student_id: @student.id)
  end

  private

  def load_student
    @student = Student.find(params[:id])
  end

end
