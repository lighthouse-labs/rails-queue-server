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

  def cohort_name
    result = "<a href='#'>#{student.cohort.name}</a>"
    result.html_safe
  end

  def contact
    result = "<p>Email: #{student.email}</p>"
    result += "<p>Phone #: #{student.phone_number}</p>"
    result += "<a href='www.github.com/#{student.github_username}'>GitHub Account</a>"
    result.html_safe
  end

  def prep_activity_stats
    completed_activities = student.activity_submissions.joins(:activity, :section).where("sections.type = 'Prep'").count
    total_activities = Activity.joins(:section).where("sections.type = 'Prep'").count
    activity_ratio = completed_activities > 0 ? (completed_activities.to_f / total_activities) * 100 : 0
    result = "<div class='stats'><p>#{completed_activities} of #{total_activities} activities</p><p>&nbsp</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{activity_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{activity_ratio}%'>"
    result += "<span class='sr-only'>#{activity_ratio}% Complete</span></div></div>"
    result += "<p>How goes</p></div>"
    result.html_safe
  end

  def activity_stats
    completed_activities = student.activity_submissions.count
    total_activities = Activity.count
    activity_ratio = completed_activities > 0 ? (completed_activities.to_f / total_activities) * 100 : 0
    result = "<div class='stats'><p>#{completed_activities} of #{total_activities} activities</p><p>&nbsp</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{activity_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{activity_ratio}%'>"
    result += "<span class='sr-only'>#{activity_ratio}% Complete</span></div></div>"
    result += "<p>How goes</p></div>"
    result.html_safe
  end

  def quiz_stats
    quiz_submissions = student.quiz_submissions.where(initial: true).count
    total_quizzes = Quiz.count
    quiz_ratio = quiz_submissions > 0 ? (quiz_submissions.to_f / total_quizzes) * 100 : 0
    quiz_average = student.quiz_submissions.count > 0 ? (student.quiz_submissions.inject(0.0) { |total, submission| total + (submission.score.to_f / submission.quiz.questions.count)} / student.quiz_submissions.count * 100).to_i : 0
    result = "<div class='stats'><p>#{quiz_submissions} of #{total_quizzes} quizzes</p>"
    result += "<p>Average: #{quiz_average}</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{quiz_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{quiz_ratio}%'>"
    result += "<span class='sr-only'>#{quiz_ratio}% Complete</span></div></div>"
    result += "<p>How goes</p></div>"
    result.html_safe
  end

  def outcomes_table
    skills = Skill.outcomes.outcome_results.average(:rating).where("outcomes.outcome_results.user_id = ?", student.id)
  end

end
