class ActivitySerializer < ActiveModel::Serializer

  format_keys :lower_camel
  attributes :id, :uuid, :day, :name, :type

  has_one :project

  def project
    object.section if object.section&.is_a?(Project)
  end

end
