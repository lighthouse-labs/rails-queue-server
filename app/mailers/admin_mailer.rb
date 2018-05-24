class AdminMailer < ActionMailer::Base

  default from: ENV['EMAIL_SENDER'], to: ENV['SUPER_ADMIN_EMAIL']

  def new_teacher_joined(teacher)
    @teacher = teacher
    @host = ENV['HOST']
    to = teacher.location.try(:feedback_email) || ENV['SUPER_ADMIN_EMAIL']

    mail subject: 'New Teacher Joined', to: to
  end

  def new_day_feedback(feedback)
    @feedback = feedback
    @host = ENV['HOST']

    to = feedback.student.location.try(:feedback_email)
    # incase feedback_email is nil or empty string (not just nil)
    to = ENV['SUPER_ADMIN_EMAIL'] if to.blank?

    mail(
      subject:  "Student Feedback (#{feedback.day}) [\##{feedback.id}]",
      reply_to: feedback.student.email,
      to:       to
    )
  end

  def weekly_digest(feedbacks)
    @feedbacks = feedbacks
    @host = ENV['HOST']
    to = Program.first.curriculum_team_email

    mail subject: 'Weekly Digest of Negative Curriculum Feedback', to: to
  end

end
