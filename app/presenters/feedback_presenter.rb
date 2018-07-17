class FeedbackPresenter < BasePresenter

  presents :feedback

  delegate :notes, :rating, :updated_at, :feedbackable, :technical_rating, :style_rating, :student, :teacher, to: :feedback

  def truncated_notes
    truncate feedback.notes, length: 200 if feedback.notes.present?
  end

  def upcased_day
    if feedback.try(:feedbackable).try(:day) 
      feedback.feedbackable.day.upcase
    elsif feedback.student.present?
      CurriculumDay.new(feedback.created_at.to_date, feedback.student.cohort).to_s.upcase
    else
      # If the student is no longer registered for some reason, display just the date
      feedback.created_at.to_date.to_s
    end
  end

  def feedbackable_name
    if feedback.try(:feedbackable).try(:name)
      feedback.feedbackable.name
    elsif feedback.try(:feedbackable).try(:project)
      feedback.feedbackable.project.name
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
    if teacher.github_username?
      render(
        'shared/social_icon',
        handle:  teacher.github_username,
        company: 'github',
        url:     "https://github.com/#{teacher.github_username}"
      )
    end
  end

  def slack_info(teacher)
    if teacher.slack?
      render(
        'shared/social_icon',
        handle:  teacher.slack,
        company: 'slack'
      )
    end
  end

  def teacher
    feedback.teacher.presence || 'N/A'
  end

  def assistance_request_reason
    if feedback.feedbackable_type == "Assistance"
      assistance_request = AssistanceRequest.find_by(assistance_id: feedback.feedbackable_id)
      assistance_request&.reason
    else
      'N/A'
    end
  end

  def date
    feedback.updated_at.to_date.to_s
  end

end
