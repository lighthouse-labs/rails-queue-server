class QueueLocationSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :name

  # has_many :whatwhat
  has_many :students, serializer: QueueStudentSerializer
  has_many :assistances, serializer: QueueAssistanceSerializer
  has_many :requests

  def students
    # raise object.inspect
    Student.active.where(location_id: object).where(cohort: Cohort.is_active)
  end

  def assistances
    Assistance.currently_active.with_user_location_id(object)
  end

  def requests
    AssistanceRequest.genuine.open_requests.for_location(object)
  end

end
