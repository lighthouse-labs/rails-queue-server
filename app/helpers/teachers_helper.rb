module TeachersHelper
  def url_for_proctologist(test, cohort)
    student_usernames = cohort.students.active.map do |s|
      if s.rolled_in?(cohort)
        "#{s.github_username}-1"
      else
        s.github_username
      end
    end
    student_usernames = student_usernames.join(',')
    url = URI("#{cohort.program.proctor_url}/admin/exams/#{test}/?studentIds=#{student_usernames}")

    url.user = "admin"
    url.password = "Fresnel"

    url.to_s
  end
end
