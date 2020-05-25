class FeedbackSerializer < ActiveModel::Serializer

  root false

  attributes :technical_rating, :style_rating, :notes, :feedbackable_id, :rating

end
