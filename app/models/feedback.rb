class Feedback < ApplicationRecord

  belongs_to :feedbackable, polymorphic: true
  belongs_to :assistor, class_name: User, foreign_key: "assistor_uid", primary_key: 'uid'
  belongs_to :assistee, class_name: User, foreign_key: "assistee_uid", primary_key: 'uid'

  before_create :creation_webhooks

  scope :assistor_feedbacks, -> { where.not(assistor: nil) }
  scope :expired, -> { where("feedbacks.created_at < ?", Time.zone.today - 1) }
  scope :not_expired, -> { where("feedbacks.created_at >= ?", Time.zone.today - 1) }
  scope :completed, -> { where.not(rating: nil) }
  scope :pending, -> { where(rating: nil) }
  scope :reverse_chronological_order, -> { order("feedbacks.updated_at DESC") }
  scope :filter_by_assistor, ->(assistor_uid) { where("assistor_uid = ?", assistor_uid) }
  scope :filter_by_assistee, ->(assistee_uid) { where("assistee_uid = ?", assistee_uid) }

  scope :assistance, -> { where(feedbackable_type: 'Assistance') }
  scope :direct, -> { where(feedbackable_type: nil) }

  scope :filter_by_start_date, ->(date_str) { where("feedbacks.updated_at >= ?", date_str) }

  scope :filter_by_end_date, ->(date_str) { where("feedbacks.updated_at <= ?", date_str) }

  validates :rating, presence: true, on: :update

  def self.average_rating
    average(:rating).to_f.round(2)
  end

  private

  def creation_webhooks
    Webhooks::Requests.call(
      model:         'Feedback',
      resource_type: feedbackable.class.name,
      action:        'create',
      object:        self,
      compass_instance: feedbackable.try(:assistance_request)&.compass_instance
    )
  end

end
