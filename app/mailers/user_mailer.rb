class UserMailer < ActionMailer::Base

  add_template_helper(ActivitiesHelper)

  default from: ENV['EMAIL_SENDER']

  def new_activity_message(message)
    @message = message
    students = @message.cohort.students.active
    mail  subject: "#{@message.day.upcase} #{@message.kind}: #{@message.subject}",
          to:      @message.cohort.teacher_email_group || ENV['INSTRUCTOR_EMAIL_GROUP'] || ENV['EMAIL_SENDER'],
          bcc:     students.pluck(:email)
  end

  def new_code_review_message(code_review)
    @message = code_review.student_notes

    if assistance_request = code_review.assistance_request
      @activity_name = assistance_request.activity.try :name
      @submission_url = assistance_request.activity_submission.try(:github_url)
    end
    student = code_review.assistee
    @reviewer = code_review.assistor

    feedback_email = student.cohort.location.feedback_email

    mail  subject:  "Lighthouse Labs Code Review: #{student.full_name}",
          to:       student.email,
          reply_to: @reviewer.email,
          cc:       @reviewer.email,
          bcc:      feedback_email
  end

  def new_tech_interview_message(tech_interview)
    @tech_interview = tech_interview
    @interviewer    = tech_interview.interviewer
    @interviewee    = tech_interview.interviewee

    feedback_email  = @interviewee.cohort.location.feedback_email

    mail  subject:  "LHL Week #{@tech_interview.week} Interview: #{@interviewee.full_name}",
          to:       @interviewee.email,
          reply_to: @interviewer.email,
          cc:       @interviewer.email,
          bcc:      feedback_email
  end

  # v2 (remove the evaluation_accepted and evaluation_rejected along with other non-v2 eval logic)
  # when removing v2 logic, there are old evals that will always be v1, so v1 vs v2 conditionals for show should not be removed
  def evaluation_result(evaluation)
    @evaluation = evaluation
    @student    = evaluation.student
    @teacher    = evaluation.teacher
    @project    = evaluation.project

    feedback_email = @evaluation.cohort.location.feedback_email

    mail  subject: "LHL Project #{@evaluation.in_state?(:accepted) ? 'Accepted' : 'Rejected'}: #{@student.full_name}!",
          to:      @student.email,
          from:    @teacher.email,
          cc:      @teacher.email,
          bcc:     feedback_email
  end

  def evaluation_accepted(evaluation)
    @evaluation = evaluation
    @student    = evaluation.student
    @teacher    = evaluation.teacher
    @project    = evaluation.project

    feedback_email = @evaluation.cohort.location.feedback_email

    mail  subject: "LHL Project Accepted: #{@student.full_name}!",
          to:      @student.email,
          from:    @teacher.email,
          cc:      @teacher.email,
          bcc:     feedback_email
  end

  def evaluation_rejected(evaluation)
    @evaluation = evaluation
    @student    = evaluation.student
    @teacher    = evaluation.teacher
    @project    = evaluation.project

    feedback_email = @evaluation.cohort.location.feedback_email

    mail  subject: "LHL Project Rejected: #{@student.full_name}!",
          to:      @student.email,
          from:    @teacher.email,
          cc:      @teacher.email,
          bcc:     feedback_email
  end

  def notify_education_manager(assistance)
    @student = assistance.assistee
    @teacher = assistance.assistor
    @notes = assistance.notes
    @rating = assistance.rating
    @cohort = @student.cohort.name
    @date = assistance.end_at

    location = @student.location.education_manager_location.name.upcase
    email = @student.location.flagged_assistance_email || ENV['SUPER_ADMIN_EMAIL']

    mail  subject: "Flagged Assistance Notification",
          to:      email
  end

end
