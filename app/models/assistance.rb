class Assistance < ApplicationRecord

  include PgSearch
  allow_shard :master
  # belongs_to :assistor, class_name: User, foreign_key: "assistor_uid", primary_key: 'uid'

  has_one :feedback, as: :feedbackable, dependent: :destroy
  has_one :assistance_request, dependent: :nullify

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4, allow_nil: true }

  before_create :set_start_at

  scope :in_progress, -> {
    where("end_at IS NULL")
  }
  scope :closed, -> { where('assistances.end_at IS NOT NULL') }
  scope :completed, -> { where('assistances.end_at IS NOT NULL') }
  scope :has_assistance_request, -> { joins(:assistance_request) }
  scope :order_by_start, -> { order(:start_at) }
  scope :assisted_by, ->(user) { where(assistor_uid: user.uid) }
  # 2ADD for user needs to be any assistance for a user not only requested ones
  scope :for_user, ->(uid) {joins(:assistance_request).where("assistance_requests.requestor->>'uid' = ?", uid)}
  scope :requested_by, ->(uid) {joins(:assistance_request).where("assistance_requests.requestor->>'uid' = ?", uid)}
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
    User.using(:web).find_by(uid: assistor_uid)
  end

  private

  def set_start_at
    self.start_at ||= Time.current
  end

end
