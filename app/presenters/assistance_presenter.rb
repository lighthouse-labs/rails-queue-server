class AssistancePresenter < BasePresenter

  presents :assistance

  def activity
    if assistance.activity
      link_to assistance.activity.name.to_s, day_activity_path(assistance.activity.day, assistance.activity.id)
    else
      "No Activity"
    end
  end

  def formatted_date
    assistance.start_at.strftime('%B %d, %Y').to_s
  end

  def duration
    if assistance.end_at
      distance_of_time_in_words(assistance.start_at, assistance.end_at).to_s
    else
      "In Progress"
    end
  end

end
