class MyLocationSerializer < ActiveModel::Serializer

  root false
  format_keys :lower_camel

  attributes :id, :name

end
