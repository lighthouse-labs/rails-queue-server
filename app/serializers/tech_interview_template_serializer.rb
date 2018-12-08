class TechInterviewTemplateSerializer < ActiveModel::Serializer

  root false

  attributes :id, :week, :description
  format_keys :lower_camel

end
