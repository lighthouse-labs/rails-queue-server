class StudentPresenter < UserPresenter

  presents :student

  def avatar
    image_tag student.avatar_url, width: '15%'
  end

  def name
    content_tag :h3, student.full_name, class: 'student-details-name'
  end

  def cohort_name_link
    link_to student.cohort.name, cohort_students_path(student.cohort)
  end

  def cohort_date_link
    date = student.cohort.start_date.strftime("%B %Y")
    link_to date, cohort_students_path(student.cohort)
  end

  def contact
    result = "<p>Email: #{student.email}</p>"
    result += "<p>Phone #: #{student.phone_number}</p>"
    result += "<a href='http://www.github.com/#{student.github_username}'>GitHub Account</a>"
    result.html_safe
  end

  def day_button
    if student.cohort.try(:upcoming?)
      days = (student.cohort.start_date - Date.current).to_i
      link_to "#{days} days to start", '#', class: "btn btn-default"
    elsif student.cohort.try(:active?)
      day = CurriculumDay.new(Date.current, student.cohort).to_s.upcase
      link_to "#{day}", day_path('today'), class: "btn btn-default"
    elsif student.cohort.try(:finished?)
      link_to "Alumni", '#', class: "btn btn-default"
    end
  end

  def prep_activity_stats
    completed_activities = student.activity_submissions.proper.joins(activity: [:section]).where(sections: { type: 'Prep' }).count
    total_activities = Activity.joins(:section).where(sections: { type: 'Prep' }).count
    activity_ratio = total_activities > 0 ? (completed_activities.to_f / total_activities.to_f) * 100 : 0
    result = "<div class='stats'><p><strong>Activities</strong>"
    result += "<p>#{completed_activities} of #{total_activities}</p><p>&nbsp</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{activity_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{activity_ratio}%'>"
    result += "<span class='sr-only'>#{activity_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def prep_quiz_stats
    quiz_ids = Quiz.joins(quiz_activities: [:section]).where(sections: { type: 'Prep' }).select(:id)
    quiz_submissions = student.quiz_submissions.where(quiz_id: quiz_ids).where(initial: true)
    quiz_ratio = quiz_submissions.count > 0 ? (quiz_submissions.count.to_f / quiz_ids.count) * 100 : 0
    quiz_average = average_score_for_submissions(quiz_submissions)
    result = "<div class='stats'><p><strong>Quizzes</strong></p>"
    result += "<p>#{quiz_submissions.count} of #{quiz_ids.count}</p>"
    result += "<p>Average: #{quiz_average.to_i}</p>" if quiz_average
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{quiz_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{quiz_ratio}%'>"
    result += "<span class='sr-only'>#{quiz_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def activity_stats
    completed_activities = student.activity_submissions.proper.joins(:activity).where(activities: { section_id: nil }).count
    total_activities = Activity.count
    activity_ratio = completed_activities > 0 ? (completed_activities.to_f / total_activities) * 100 : 0
    result = "<div class='stats'><p><strong>Activities</strong>"
    result += "<p>#{completed_activities} of #{total_activities}</p>"
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{activity_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{activity_ratio}%'>"
    result += "<span class='sr-only'>#{activity_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def quiz_stats
    quiz_submissions = student.quiz_submissions.joins(quiz: [:quiz_activities]).where(initial: true).where(activities: { section_id: nil })
    total_quizzes = Quiz.count
    quiz_ratio = quiz_submissions.any? ? (quiz_submissions.to_f / total_quizzes) * 100 : 0
    quiz_average = average_score_for_submissions(quiz_submissions)
    result = "<div class='stats'><p><strong>Quizzes</strong></p>"
    result += "<p>#{quiz_submissions.count} of #{total_quizzes}</p>"
    result += "<p>Average: #{quiz_average.to_i}</p>" if quiz_average
    result += "<div class='progress'><div class='progress-bar' role='progressbar'"
    result += "aria-valuenow='#{quiz_ratio}' aria-valuemin='0' aria-valuemax='100' style='width:#{quiz_ratio}%'>"
    result += "<span class='sr-only'>#{quiz_ratio}% Complete</span></div></div>"
    result += "<p>Status</p></div>"
    result.html_safe
  end

  def assistance_stats
    #TO DO - this uses dummy data, replace it with real data.
    result = "<div class='stats'><p><strong>Assistances</strong></p>"
    result += "<p>? of ?</p>"
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
    result += "<th>Activities</th><th>Avg Quiz Score</th></thead><tbody>"
    Prep.all.each do |p|
      activity_submissions = p.activity_submissions.proper.where(user_id: student.id).count
      total_activities = p.activities.count
      quiz_average = average_quiz_score_for_section(p)
      result += "<tr><td>#{p.name}</td>"
      result += "<td>#{activity_submissions}/#{total_activities}</td>"
      if quiz_average
        result += "<td>#{quiz_average}%</td>"
      else
        result += "<td>N/A</td>"
      end
      result += "</tr>"
    end
    result += "</tbody></table>"
    result.html_safe
  end

  private

  def average_quiz_score_for_section(s)
    quiz_ids = Quiz.joins(quiz_activities: [:section]).where(sections: {id: s.id}).select(:id)
    quiz_submissions = student.quiz_submissions.where(quiz_id: quiz_ids).where(initial: true)
    average_score_for_submissions(quiz_submissions).to_i if quiz_submissions.any?
  end

  def average_score_for_submissions(submissions)
    if submissions.any?
      submissions.inject(0.0) { |sum, submission| sum + (submission.score.to_f / submission.quiz.questions.count)} / submissions.count.to_f * 100.0
    else
      nil
    end
  end

end
