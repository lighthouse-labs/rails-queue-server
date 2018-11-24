class QueueSerializer < ActiveModel::Serializer

  # object = Program instance

  format_keys :lower_camel
  has_many :locations, serializer: QueueLocationSerializer

  def locations
    Location.limit(2)
  end

end
