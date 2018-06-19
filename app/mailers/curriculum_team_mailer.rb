class CurriculumTeamMailer < ActionMailer::Base

  default from: ENV['EMAIL_SENDER']
  layout 'new_mailer'

  def weekly_digest(feedbacks_by_activity, program)
    @feedbacks_by_activity = feedbacks_by_activity
    @program = program
    date = Date.current.to_s(:db)
    subject = "Negative Curriculum Feedback (#{program.name}) - Week of #{date}"
    mail subject: subject, to: program.curriculum_team_email
  end

end
