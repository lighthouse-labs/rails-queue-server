class Assistance < ApplicationRecord

  include PgSearch::Model
  allow_shard :master
  # belongs_to :assistor, class_name: User, foreign_key: "assistor_uid", primary_key: 'uid'

  has_one :feedback, as: :feedbackable, dependent: :destroy
  has_one :assistance_request, dependent: :nullify

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4, allow_nil: true }

  before_create :set_start_at, :creation_webhooks

  scope :in_progress, -> {
    where("end_at IS NULL")
  }
  scope :closed, -> { where('assistances.end_at IS NOT NULL') }
  scope :completed, -> { where('assistances.end_at IS NOT NULL') }
  scope :has_assistance_request, -> { joins(:assistance_request) }
  scope :order_by_start, -> { order(:start_at) }
  scope :assisted_by, ->(user) { where(assistor_uid: user.uid) }
  scope :for_user, ->(uid) { joins(:assistance_request).where("assistance_requests.requestor->>'uid' = ?", uid) }
  scope :requested_by, ->(uid) { joins(:assistance_request).where("assistance_requests.requestor->>'uid' = ?", uid) }
  scope :for_resource, ->(resource) { where(resource_type: resource) }
  scope :without_feedback, -> { left_outer_joins(:feedback).where(feedbacks: { feedbackable_id: nil }) }
  scope :with_feedback_greater_than, ->(rating) { joins(:feedback).where("feedbacks.rating > ?", rating) }
  scope :with_feedback_less_than, ->(rating) { joins(:feedback).where("feedbacks.rating < ?", rating) }
  scope :average_feedback_rating, -> { joins(:feedback).average("feedbacks.rating") }

  scope :has_feedback, -> { joins(:feedback) }

  scope :average_length, -> { average('EXTRACT(EPOCH FROM (assistances.end_at - assistances.start_at)) / 60.0').to_f }

  RATING_BASELINE = 3

  def end(notes, notify, rating = nil, student_notes = nil)
    self.notes = notes
    self.rating = rating
    self.student_notes = student_notes
    self.end_at = Time.current
    self.flag = notify
    UserMailer.notify_education_manager(self).deliver_later if flag?
    result = Webhooks::Requests.call(
      model:         'Assistance',
      resource_type: assistance_request.request.try(:[], 'resourceType'),
      action:        'end',
      object:        self,
      compass_instance: assistance_request.compass_instance
    )
    save!
  end

  def in_progress?
    end_at.nil?
  end

  def state
    if in_progress?
      'in_progress'
    else
      'closed'
    end
  end

  def assistor
    db_results = Octopus.using_group(:program_shards) do
      user = User.find_by(uid: assistor_uid)
      return user if user.present?
    end
    nil
  end

  private

  def set_start_at
    self.start_at ||= Time.current
  end

  def creation_webhooks
    Webhooks::Requests.call(
      model:         'Assistance',
      resource_type: assistance_request.request.try(:[], 'resourceType'),
      action:        'create',
      object:        self,
      compass_instance: assistance_request.compass_instance
    )
  end

end
