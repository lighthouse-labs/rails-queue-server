module Admin::ProgrammingTestsHelper

  def programming_tests
    @programming_tests.map do |pt|
      { name: pt.test_activities.first.name, code: pt.exam_code }
    end
  end

  def active_students(cohort, programming_test)
    cohort.students.active.map do |s|
      {
        name:         s.full_name,
        enrollmentId: s.enrollment_id(cohort),
        detailsPath:  teacher_cohort_programming_test_student_submission_path(cohort, programming_test, s)
      }
    end
  end

end
