class AssistanceRequest < ApplicationRecord

  belongs_to :assistance, dependent: :delete
  belongs_to :compass_instance

  has_many :queue_tasks

  before_create :set_start_at

  scope :open_requests, -> { where(canceled_at: nil).where(assistance_id: nil) }
  scope :closed, -> {
    where(canceled_at: nil)
    .where.not(assistance_id: nil)
    .includes(:assistance)
    .references(:assistance)
    .where.not(assistances: { end_at: nil })
  }
  scope :requested_by, ->(uid) {
    where("requestor->>'uid' = ?", uid)
  }
  scope :in_progress_requests, -> {
    includes(:assistance)
      .where(assistance_requests: { canceled_at: nil })
      .where.not(assistances: { id: nil })
      .where(assistances: { end_at: nil })
      .references(:assistance)
  }
  scope :open_or_in_progress_requests, -> {
    includes(:assistance)
      .where(assistance_requests: { canceled_at: nil })
      .where("assistances.id IS NULL OR assistances.end_at IS NULL")
      .references(:assistance)
  }

  scope :oldest_requests_first, -> { order(start_at: :asc) }
  scope :newest_requests_first, -> { order(start_at: :desc) }
  scope :code_reviews, -> { where(type: 'CodeReviewRequest') }
  scope :between_dates, ->(start_date, end_date) { where(start_at: start_date..end_date) }

  scope :wait_times_between, ->(low, high) {
    where('(EXTRACT(EPOCH FROM (assistances.start_at - assistance_requests.start_at)) / 60.0)::float BETWEEN ? AND ?', low, high)
  }

  def cancel
    self.canceled_at = Time.current
    save
  end

  def start_assistance(assistor)
    return false if assistor.blank? || assistance.present?

    if compass_instance.has_feature?('assistance_hangouts')
      google_hangout = GoogleHangout.new
      google_hangout = google_hangout.create_hangout(assistor, requestor)
    end
    google_hangout ||= {}

    self.assistance = Assistance.new(
      assistor:        assistor,
      assistee:        requestor,
      activity:        activity,
      conference_link: google_hangout[:uri],
      conference_type: google_hangout[:type]
    )
    assistance if assistance.save!
  end

  def assign_task(assistor)
    return false if assistor.blank? || assistance.present?

    queue_tasks.create(user: assistor)
  end

  def end_assistance(notes)
    return if assistance.blank?

    assistance.end(notes)
  end

  def cancel_assistance
    self.assistance = nil
    save!
  end

  def open?
    assistance.nil? && canceled_at.nil?
  end

  def in_progress?
    canceled_at.nil? && assistance && assistance.end_at.nil?
  end

  def state
    if in_progress?
      'in_progress'
    elsif open?
      'pending'
    else
      'closed'
    end
  end

  def position_in_queue
    queue_tasks&.map(&:position_in_queue).max if open?
  end

  private

  def set_cohort
    self.cohort_id = requestor.try :cohort_id
  end

  def set_start_at
    self.start_at ||= Time.current
  end

end
