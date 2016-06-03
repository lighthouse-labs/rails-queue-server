class StudentPresenter < UserPresenter

  presents :student

  def avatar
    result = "<img src='#{student.avatar_url}' width='15%'/>"
    result.html_safe
  end

  def name
    result = "<h3 class='student-details-name'>#{student.full_name}</h3>"
    result.html_safe
  end

  def cohort_name_link
    #result = "<a href='#'>#{student.cohort.name}</a>"
    result = link_to student.cohort.name, cohort_students_path(student.cohort)
    result.html_safe
  end

  def cohort_date_link
    date = student.cohort.start_date.strftime("%B %Y")
    result = link_to date, cohort_students_path(student.cohort)
    result.html_safe
  end

  def contact
    result = "<p>Email: #{student.email}</p>"
    result += "<p>Phone #: #{student.phone_number}</p>"
    result += "<a href='http://www.github.com/#{student.github_username}'>GitHub Account</a>"
    result.html_safe
  end

  def day_button
    day = CurriculumDay.new(Date.current, student.cohort).to_s.upcase
    link_to "#{day}", day_path('today'), class: "btn btn-default"
  end

  def prep_activity_stats
    completed_activities = student.activity_submissions.joins(activity: [:section]).where("sections.type = 'Prep'").count
    total_activities = Activity.joins(:section).where("sections.type = 'Prep'").count
    activity_ratio = completed_activities > 0 ? (completed_activities.to_f / total_activities) * 100 : 0
    result = "<div class='stats'><p><strong>Activities</strong>"
    result += "<p>#{completed_activities} of #{total_activities}</p><p>&nbsp</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{activity_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{activity_ratio}%'>"
    result += "<span class='sr-only'>#{activity_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def prep_quiz_stats
    quiz_ids = Quiz.joins(quiz_activities: [:section]).where("sections.type = 'Prep'").select(:id)
    quiz_submissions = student.quiz_submissions.where(quiz_id: quiz_ids).where(initial: true)
    quiz_ratio = quiz_submissions.count > 0 ? (quiz_submissions.count.to_f / quiz_ids.count) * 100 : 0
    quiz_average = student.quiz_submissions.count > 0 ? (student.quiz_submissions.inject(0.0) { |total, submission| total + (submission.score.to_f / submission.quiz.questions.count)} / student.quiz_submissions.count * 100).to_i : 0
    result = "<div class='stats'><p><strong>Quizzes</strong></p>"
    result += "<p>#{quiz_submissions.count} of #{quiz_ids.count}</p><p>Average: #{quiz_average}</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{quiz_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{quiz_ratio}%'>"
    result += "<span class='sr-only'>#{quiz_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe

  end

  def activity_stats
    completed_activities = student.activity_submissions.joins(:activity).where("activities.section_id = null").count
    total_activities = Activity.count
    activity_ratio = completed_activities > 0 ? (completed_activities.to_f / total_activities) * 100 : 0
    result = "<div class='stats'><p><strong>Activities</strong>"
    result += "<p>#{completed_activities} of #{total_activities}</p><p>&nbsp</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{activity_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{activity_ratio}%'>"
    result += "<span class='sr-only'>#{activity_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def quiz_stats
    quiz_submissions = student.quiz_submissions.joins(quiz: [:quiz_activities]).where(initial: true).where("activities.section_id = null").count
    total_quizzes = Quiz.count
    quiz_ratio = quiz_submissions > 0 ? (quiz_submissions.to_f / total_quizzes) * 100 : 0
    quiz_average = student.quiz_submissions.count > 0 ? (student.quiz_submissions.inject(0.0) { |total, submission| total + (submission.score.to_f / submission.quiz.questions.count)} / student.quiz_submissions.count * 100).to_i : 0
    result = "<div class='stats'><p><strong>Quizzes</strong></p>"
    result += "<p>#{quiz_submissions} of #{total_quizzes}</p><p>Average: #{quiz_average}</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{quiz_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{quiz_ratio}%'>"
    result += "<span class='sr-only'>#{quiz_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def assistance_stats
    #TO DO - this uses dummy data, replace it with real data.
    result = "<div class='stats'><p><strong>Assistances</strong></p>"
    result += "<p>1</p><p>&nbsp</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='50' aria-valuemin='0' aria-valuemax='100' style='width:50%'>"
    result += "<span class='sr-only'>50% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def outcomes_table
    skills = student.outcome_results.group("skills.name").joins(outcome: [:skill]).average(:rating)
    result = "<table class='table'><thead><th>Skill</th><th>Average Rating</th></thead><tbody>"
    skills.each { |k,v| result += "<tr><td>#{k.titleize}</td><td>#{'X' * v}</td></tr>" }
    result += "</tbody></table>"
    result.html_safe
  end

  def prep_table
    result = "<table class='table'><thead><th>Module</th>"
    result += "<th>Activities</th><th>Quizzes AVG</th></thead><tbody>"
    Prep.all.each do |p|
      activity_submissions = p.activity_submissions.where(user_id: student.id).count
      total_activities = p.activities.count
      quiz_ids = Quiz.joins(quiz_activities: [:section]).where("sections.id = #{p.id}").select(:id)
      quiz_submissions = student.quiz_submissions.where(quiz_id: quiz_ids).where(initial: true)
      quiz_average = quiz_submissions.count > 0 ? (quiz_submissions.inject(0.0) { |sum, submission| sum + (submission.score.to_f / submission.quiz.questions.count)} / student.quiz_submissions.count * 100).to_i : 0
      result += "<tr><td>#{p.name}</td>"
      result += "<td>#{activity_submissions}/#{total_activities}</td>"
      result += "<td>#{quiz_average}%</td></tr>"
    end
    result += "</tbody></table>"
    result.html_safe
  end

end
