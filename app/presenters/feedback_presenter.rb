class FeedbackPresenter < BasePresenter
  presents :feedback

  delegate :notes, :rating, :updated_at, :feedbackable, :technical_rating, :style_rating, :student, :teacher, to: :feedback

  def truncated_notes
    if feedback.notes.present?
      truncate feedback.notes, length: 200
    end
  end

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

  def feedbackable_name
    if feedback.try(:feedbackable) && feedback.feedbackable.try(:name)
      feedback.feedbackable.name
    elsif feedback.try(:feedbackable)
      'N/A'
    else
      ''
    end
  end

  def feedbackable_type
    if feedback.try(:feedbackable) && feedback.feedbackable.try(:type)
      feedback.feedbackable.type
    elsif feedback.try(:feedbackable)
      feedback.feedbackable.class.name
    else
      'Direct Feedback'
    end
  end

  def teacher_full_name
    if feedback.teacher.present?
      feedback.teacher.first_name + " " + feedback.teacher.last_name
    else
      'N/A'
    end
  end

  def student_full_name
    if feedback.student.present?
      feedback.student.first_name + " " + feedback.student.last_name
    else
      'N/A'
    end
  end

  def github_info(teacher)
    render(
      'shared/social_icon',
      handle: teacher.github_username,
      company: 'github',
      url: "https://github.com/#{teacher.github_username}"
    ) if teacher.github_username?
  end

  def slack_info(teacher)
    render(
      'shared/social_icon',
      handle: teacher.slack,
      company: 'slack'
    ) if teacher.slack?
  end

  def teacher
    if feedback.teacher.present?
      feedback.teacher
    else
      'N/A'
    end
  end

  def assistance_request_reason
    if feedback.feedbackable_type == "Assistance"
      assistance_request = AssistanceRequest.find_by(id: feedback.feedbackable_id)
      if assistance_request
        assistance_request.reason
      end
    else
      'N/A'
    end
  end

  def date
    feedback.created_at.to_date.to_s
  end

end