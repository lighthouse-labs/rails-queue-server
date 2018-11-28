class QueueLocationSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes :id, :name

  has_many :students, serializer: QueueStudentSerializer
  has_many :assistances, serializer: QueueAssistanceSerializer
  has_many :requests
  has_many :pending_evaluations
  has_many :in_progress_evaluations
  has_many :in_progress_interviews
  # see below
  # has_many :pending_interviews, serializer: PendingTechInterviewSerializer

  def pending_evaluations
    Evaluation.open_evaluations.student_location(object).student_priority
  end

  def in_progress_evaluations
    Evaluation.in_progress_evaluations.student_location(object).student_priority
  end

  def in_progress_interviews
    TechInterview.in_progress.oldest_first.interviewee_location(object)
  end

  def students
    Student.active.where(location_id: object).in_active_cohort.order_by_name
  end

  def assistances
    Assistance.currently_active.with_user_location_id(object)
  end

  def requests
    AssistanceRequest.genuine.open_requests.for_location(object)
  end

  # Consider enabling / adding this in the near future. Ignore for now - KV
  # def pending_interviews
  #   Student.active.where(location_id: object).in_active_cohort.order_by_name.map do |student|
  #     cohort = student.cohort
  #     TechInterviewTemplate.due_for_cohort(cohort).where.not(id: TechInterview.interviewing(student, cohort).select(:tech_interview_template_id)).map do |ti_template|
  #       ti_template.tech_interviews.new(interviewee: student, cohort: cohort)
  #     end
  #   end.flatten.compact
  # end

end
