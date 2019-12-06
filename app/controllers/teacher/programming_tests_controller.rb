class Teacher::ProgrammingTestsController < Teacher::BaseController

  before_action :load_programming_tests
  before_action :load_cohort
  before_action :check_permissions

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

  def check_permissions
    redirect_to '/', alert: 'Not Allowed, Champ.' unless current_user.can_view_programming_tests?
  end

end