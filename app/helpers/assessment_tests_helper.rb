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

  def exam_codes
    [
      { name: "W1 Test (Mock Test)", code: "web-01" },
      { name: "W2 Test", code: "web-02d" },
      { name: "W3 Test", code: "web-03gg" },
      { name: "W4 Test", code: "web-04yo" },
      { name: "W5 Test (SQL)", code: "web-05sh" },
      { name: "W10 Test (Ruby)", code: "web-06-rb" }
    ]
  end

end
