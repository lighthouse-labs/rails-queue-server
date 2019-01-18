class CohortSerializer < ActiveModel::Serializer

  format_keys :lower_camel

  attributes :id, :name, :local_assistance_queue

  has_one :location
  has_one :week

end
