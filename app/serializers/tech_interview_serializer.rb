class TechInterviewSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes :id, :created_at, :started_at, :completed_at, :type, :state

  has_one :tech_interview_template, serializer: TechInterviewTemplateSerializer
  has_one :interviewer, serializer: TeacherSerializer
  has_one :interviewee, serializer: QueueStudentSerializer

  def type
    'TechInterview'
  end

  delegate :state, to: :object

end
