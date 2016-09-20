class TechInterviewSerializer < ActiveModel::Serializer

  root false

  attributes :id, :created_at, :started_at, :completed_at

  has_one :tech_interview_template, serializer: TechInterviewTemplateSerializer
  has_one :interviewer, serializer: UserSerializer
  has_one :interviewee, serializer: UserSerializer

end
