class ActivityFeedbackPresenter < BasePresenter

  presents :activity_feedback

  delegate :detail, to: :activity_feedback

  def truncated_detail
    truncate feedback.detail, length: 200 if activity_feedback.detail.present?
  end

  def upcased_day
    if activity_feedback.activity.day
      activity_feedback.activity.day.upcase
    else
      "Prep Course"
    end
  end

  delegate :rating, to: :activity_feedback

  def activity_name
    link_to activity_feedback.activity.name, activity_by_uuid_path(activity_feedback.activity.uuid)
  end

  def user_full_name
    if activity_feedback.user.present?
      activity_feedback.user.full_name
    else
      'N/A'
    end
  end

  def date
    activity_feedback.created_at.to_date.to_s
  end

end
