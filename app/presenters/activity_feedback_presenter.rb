class ActivityFeedbackPresenter < BasePresenter
  presents :activity_feedback

  delegate :detail, to: :activity_feedback

  def truncated_detail
    if activity_feedback.detail.present?
      truncate feedback.detail, length: 200
    end
  end

  def upcased_day
    if activity_feedback.user.present?
      CurriculumDay.new(activity_feedback.created_at.to_date, activity_feedback.user.cohort).to_s.upcase
    else
      # If the student is no longer registered for some reason, display just the date
      activity_feedback.created_at.to_date.to_s
    end
  end

  def activity_name
    activity_feedback.activity.name
  end

  def user_full_name
    if activity_feedback.user.present?
      activity_feedback.user.first_name + " " + activity_feedback.user.last_name
    else
      'N/A'
    end
  end

  def date
    activity_feedback.created_at.to_date.to_s
  end

end