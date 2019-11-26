class Admin::ProgrammingTestsController < Admin::BaseController

  ENROLLMENT_ID_REGEX = /^(.+)-(\d+)$/

  before_action :load_programming_tests

  def show; end

  def submissions
    @student = student_from_enrollment_id

    if @student.nil?
      redirect_to [:admin, :programming_tests]
    end
  end

  private

  def student_from_enrollment_id
    enrollment_id = params[:enrollment_id]

    if (matches = ENROLLMENT_ID_REGEX.match(enrollment_id))
      Student.find_by github_username: matches[1]
    end
  end

  def load_programming_tests
    @programming_tests = ProgrammingTest.active
  end

end