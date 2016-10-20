class ActivityFeedbackPresenter < BasePresenter
  presents :activity_feedback

  delegate :detail, to: :activity_feedback

  def truncated_detail
    if activity_feedback.detail.present?
      truncate feedback.detail, length: 200
    end
  end

  def upcased_day
    if activity_feedback.activity.day
      activity_feedback.activity.day.upcase
    else
      "Prep Course"
    end
  end

  def rating
    activity_feedback.rating
  end

  def activity_name
    link_to activity_feedback.activity.name, activity_by_uuid_path(activity_feedback.activity.uuid)
  end

  def user_full_name
    if activity_feedback.user.present?
      activity_feedback.user.first_name.to_s + " " + activity_feedback.user.last_name.to_s
    else
      'N/A'
    end
  end

  def date
    activity_feedback.created_at.to_date.to_s
  end

end