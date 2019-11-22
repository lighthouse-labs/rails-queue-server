class Admin::ProgrammingTestsController < Admin::BaseController

  def show
    @programming_tests = ProgrammingTest.active
  end

end