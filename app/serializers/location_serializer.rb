class LocationSerializer < ActiveModel::Serializer

  attributes :id, :name, :students

  # has_many :students, serializer: QueueStudentSerializer do
  #   Student.limit(2)
  # end

  def students
    # Student.limit(2)
    nil
  end

end
