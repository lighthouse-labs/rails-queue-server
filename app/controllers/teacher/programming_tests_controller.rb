class Teacher::ProgrammingTestsController < Teacher::BaseController

  before_action :load_programming_tests
  before_action :load_cohort

  def show
    @programming_test = ProgrammingTest.find params[:id]
  end

  private

  def load_programming_tests
    @programming_tests = ProgrammingTest.active
  end

  def load_cohort
    @cohort = Cohort.find params[:cohort_id]
  end

end