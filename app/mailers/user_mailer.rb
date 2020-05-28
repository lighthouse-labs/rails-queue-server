class UserMailer < ApplicationMailer

  add_template_helper(ActivitiesHelper)

  default from: ENV['EMAIL_SENDER']

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
