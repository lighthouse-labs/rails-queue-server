class AssistanceSerializer < ActiveModel::Serializer

  root false

  attributes :id, :start_at, :end_at, :notes, :rating, :student_notes, :flag, :conference_link, :conference_type

end
