module DaysHelper

  def day_status_css(d)
    classes = []
    classes.push('locked') unless current_user.can_access_day?(d)

    d = CurriculumDay.new(d, cohort)

    classes.push('table-success') if d.to_s == day.to_s
    classes.push('table-primary') if d.today?
    classes.push('unlocked') if d.unlocked?(current_user.location.timezone)
    classes
  end

  def feedback_submitted?(day)
    student? && current_user.day_feedbacks.find_by(day: day.to_s)
  end

  def total_cohort_students
    @total_cohort_students ||= cohort.students.active.count
  end

  def completed_students(activity)
    completed_students = if activity.is_a?(QuizActivity)
                           QuizSubmission.all.where(quiz_id: activity.quiz_id, cohort_id: cohort.id).map(&:user_id).uniq
                         else
                           activity.activity_submissions.proper.where(cohort_id: cohort.id)
                         end
    "#{completed_students.count}/#{total_cohort_students}"
  end

end
