module AssessmentTestsHelper

  def url_for_proctologist(test, cohort)
    student_usernames = cohort.students.active.map do |s|
      if s.rolled_in?(cohort)
        "#{s.github_username}-1"
      else
        s.github_username
      end
    end
    student_usernames = student_usernames.join(',')
    "#{ENV['PROCTOLOGIST_URL']}admin/exams/#{test}/?studentIds=#{student_usernames}"
  end

end
