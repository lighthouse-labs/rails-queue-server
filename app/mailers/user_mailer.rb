class UserMailer < ActionMailer::Base

  add_template_helper(ActivitiesHelper)

  default from: ENV['EMAIL_SENDER']

  def new_activity_message(message)
    @message = message
    students = @message.cohort.students.active
    mail  subject: "#{@message.day.upcase} #{@message.kind}: #{@message.subject}",
          to: @message.cohort.teacher_email_group || ENV['INSTRUCTOR_EMAIL_GROUP'] || ENV['EMAIL_SENDER'],
          bcc: students.pluck(:email)
  end

  def new_code_review_message(code_review)
    @message = code_review.student_notes

    if assistance_request = code_review.assistance_request
      @activity_name = assistance_request.activity.name
      @submission_url = assistance_request.activity_submission.try(:github_url)
    end
    student = code_review.assistee
    @reviewer = code_review.assistor
    mail  subject: "Notes from your code review with #{@reviewer.full_name} on #{code_review.created_at.to_date} ",
          to: student.email,
          cc: @reviewer.email
  end

end
