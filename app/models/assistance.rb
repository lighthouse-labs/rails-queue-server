class Assistance < ApplicationRecord

  include PgSearch

  belongs_to :assistor, class_name: User, foreign_key: "assistor_uid", primary_key: 'uid'

  has_one :feedback, as: :feedbackable, dependent: :destroy
  has_one :assistance_request, dependent: :nullify

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4, allow_nil: true }

  before_create :set_start_at

  scope :currently_active, -> {
    joins(:assistance_request)
      .where("assistance_requests.canceled_at IS NULL AND assistances.end_at IS NULL")
  }

  scope :completed, -> { where('assistances.end_at IS NOT NULL') }
  scope :has_assistance_request, -> { joins(:assistance_request) }
  scope :order_by_start, -> { order(:start_at) }
  scope :assisted_by, ->(user) { where(assistor: user) }
  scope :for_resource, ->(resource) { where(resource_type: resource)}

  scope :average_length, -> { average('EXTRACT(EPOCH FROM (assistances.end_at - assistances.start_at)) / 60.0').to_f }

  RATING_BASELINE = 3

  def end(notes, notify, rating = nil, student_notes = nil)
    self.notes = notes
    self.rating = rating
    self.student_notes = student_notes
    self.end_at = Time.current
    self.flag = notify
    save!
    assistee.last_assisted_at = Time.current

    UserMailer.notify_education_manager(self).deliver_later if flag?

    assistee.save
  end

  private

  def set_start_at
    self.start_at ||= Time.current
  end

end
