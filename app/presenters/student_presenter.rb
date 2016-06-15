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
    render 'contact_info', student: student
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
    completed_activities = student.activity_submissions.proper.prep.count
    total_activities = Activity.active.prep.count
    activity_ratio = total_activities > 0 ? (completed_activities.to_f / total_activities.to_f) * 100 : 0

    render 'stats', {
      title:    'Activities',
      count:    completed_activities,
      max:      total_activities,
      avg:      nil,
      progress: activity_ratio
    }
  end

  def prep_quiz_stats
    quiz_ids = Quiz.active.prep.select(:id)
    quiz_submissions = student.quiz_submissions.where(quiz_id: quiz_ids).where(initial: true)
    quiz_ratio = quiz_submissions.any? ? (quiz_submissions.count.to_f / quiz_ids.count) * 100 : 0
    quiz_average = average_score_for_submissions(quiz_submissions)

    render 'stats', {
      title:    'Quizzes',
      count:    quiz_submissions.count,
      max:      quiz_ids.count,
      avg:      quiz_average,
      progress: quiz_ratio
    }
  end

  def activity_stats
    completed_activities = student.activity_submissions.proper.bootcamp
    total_activities = Activity.bootcamp.active.all
    activity_ratio = total_activities.any? ? (completed_activities.count.to_f / total_activities.count) * 100 : 0

    render 'stats', {
      title:    'Activities',
      count:    completed_activities.count,
      max:      total_activities.count,
      avg:      nil,
      progress: activity_ratio
    }
  end

  def quiz_stats
    quiz_ids = Quiz.active.bootcamp.select(:id)
    quiz_submissions = student.quiz_submissions.where(quiz_id: quiz_ids).where(initial: true)
    quiz_ratio = quiz_submissions.any? ? (quiz_submissions.to_f / quiz_ids.count) * 100 : 0
    quiz_average = average_score_for_submissions(quiz_submissions)

    render 'stats', {
      title:    'Quizzes',
      count:    quiz_submissions.count,
      max:      quiz_ids.count,
      avg:      quiz_average,
      progress: quiz_ratio
    }
  end

  def assistance_stats
    # TODO - this uses dummy data, replace it with real data.
    render 'stats', {
      title:    'Assistances',
      count:    '?',
      max:      '?',
      avg:      nil,
      progress: 50
    }
  end

  def outcomes_table
    ratings = student.outcome_results.group("skills.name").joins(outcome: [:skill]).average(:rating)
    render 'skills_ratings', ratings: ratings
  end

  def prep_table
    stats = Prep.all.map do |p|
      {
        name: p.name,
        activity_submissions: p.activity_submissions.proper.where(user_id: student.id).count,
        total_activities: p.activities.count,
        quiz_average: average_quiz_score_for_section(p)
      }
    end

    render 'prep_sections', section_stats: stats
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
