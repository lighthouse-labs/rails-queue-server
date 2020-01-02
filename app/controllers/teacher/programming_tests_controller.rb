class Teacher::ProgrammingTestsController < Teacher::BaseController

  before_action :load_cohort
  before_action :load_programming_tests
  before_action :check_permissions

  def show
    @programming_test = ProgrammingTest.find params[:id]
  end

  private

  def load_programming_tests
    @active_programming_tests = ProgrammingTest.active
    @cohort_programming_tests = ProgrammingTest.for_cohort(@cohort)
    @programming_tests = (@cohort_programming_tests + @active_programming_tests).uniq
  end

  def load_cohort
    @cohort = Cohort.find params[:cohort_id]
  end

  def check_permissions
    redirect_to '/', alert: 'Not Allowed, Champ.' unless current_user.can_view_programming_tests? || current_user.admin? || current_user.super_admin?
  end

end
