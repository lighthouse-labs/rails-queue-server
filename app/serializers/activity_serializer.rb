class ActivitySerializer < ActiveModel::Serializer

  format_keys :lower_camel
  attributes :id, :uuid, :day, :name, :type

  has_one :project

  def project
    if object.section && object.section.is_a?(Project)
      object.section
    end
  end

end
