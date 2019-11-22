module Admin::ProgrammingTestsHelper

  def programming_tests
    @programming_tests.map do |pt|
      { name: pt.test_activities.first.name, code: pt.exam_code }
    end
  end

  def active_students
    cohort.students.active.map { |s| { name: s.full_name, enrollmentId: s.enrollment_id(cohort) } }
  end

end
