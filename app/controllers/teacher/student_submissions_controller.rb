class Teacher::StudentSubmissionsController < Teacher::BaseController

  before_action :load_cohort
  before_action :load_programming_test
  before_action :load_programming_tests

  def show
    @student = Student.find params[:id]
  end

  private

  def load_cohort
    @cohort = Cohort.find params[:cohort_id]
  end

  def load_programming_test
    @programming_test = ProgrammingTest.find params[:programming_test_id]
  end

  def load_programming_tests
    @programming_tests = ProgrammingTest.active
  end

end
