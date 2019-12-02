class Teacher::StudentSubmissionsController < Teacher::BaseController

  before_action :load_cohort
  before_action :load_programming_test

  def show
    @student = Student.find params[:id]
    @attempts = ProgrammingTestAttempt.includes(:programming_test).where(student: @student, cohort: @cohort)
  end

  private

  def load_cohort
    @cohort = Cohort.find params[:cohort_id]
  end

  def load_programming_test
    @programming_test = ProgrammingTest.find params[:programming_test_id]
  end

end
