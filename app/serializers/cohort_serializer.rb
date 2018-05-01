class CohortSerializer < ActiveModel::Serializer

  attributes :id, :name, :local_assistance_queue

  has_one :location
  has_one :week

end
