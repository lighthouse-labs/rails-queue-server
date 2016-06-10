class Teacher::StudentsController < Teacher::BaseController
  before_action :load_student, only: [:show]

  def index
  end

  def show
  end

  private
  def load_student
    @student = Student.find(params[:id])
  end
end