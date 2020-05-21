class FeedbackSerializer < ActiveModel::Serializer

  root false

  attributes :assistee_uid, :assistor_uid, :technical_rating, :style_rating, :notes, :feedbackable_id, :rating

end
