class ActivityFeedbackPresenter < BasePresenter
  presents :activity_feedback

  delegate :feedbackable, to: :feedback

  def upcased_day
    if feedback.try(:feedbackable)
      feedback.feedbackable.day.upcase
    elsif feedback.student.present?
      CurriculumDay.new(feedback.created_at.to_date, feedback.student.cohort).to_s.upcase
    else
      # If the student is no longer registered for some reason, display just the date
      feedback.created_at.to_date.to_s
    end
  end

end