class Webhook < ApplicationRecord

  include PgSearch::Model
  # belongs_to :assistor, class_name: User, foreign_key: "assistor_uid", primary_key: 'uid'

  belongs_to :compass_instance

  scope :for_model, ->(model) { where(model: model) }
  scope :for_action, ->(action) { where(action: action) }
  scope :for_resource_type, ->(resource_type) { where(resource_type: resource_type).or(where(resource_type: nil)) }

end
