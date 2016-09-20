module AssessmentTestsHelper

  def url_for_proctologist(test, cohort)
    student_usernames = cohort.students.active.pluck :github_username
    student_usernames = student_usernames.join(',')
    "#{ENV['PROCTOLOGIST_URL']}admin/exams/#{test}/?studentIds=#{student_usernames}"
  end

end
