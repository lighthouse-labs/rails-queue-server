class PendingTechInterviewSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes :type

  has_one :tech_interview_template, serializer: TechInterviewTemplateSerializer
  has_one :interviewee, serializer: QueueStudentSerializer

  def type
    'TechInterview'
  end

end
