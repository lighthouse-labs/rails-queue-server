class QueueLocationSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes :id, :name

  # has_many :whatwhat
  has_many :students, serializer: QueueStudentSerializer
  has_many :assistances, serializer: QueueAssistanceSerializer
  has_many :requests
  has_many :pending_evaluations
  has_many :in_progress_evaluations

  def pending_evaluations
    Evaluation.open_evaluations.student_location(object).student_priority
  end

  def in_progress_evaluations
    Evaluation.in_progress_evaluations.student_location(object).student_priority
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

end
