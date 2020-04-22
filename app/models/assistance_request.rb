class AssistanceRequest < ApplicationRecord

  belongs_to :requestor, class_name: User
  belongs_to :assistance, dependent: :delete
  belongs_to :activity
  belongs_to :cohort # substitute for lack of enrollment record - KV
  belongs_to :assistor_location, class_name: Location

  # also leads to activity, but not as 'safe' (nullable)
  # used for code review requests only (set in CodeReviewRequest class) - KV
  belongs_to :activity_submission

  has_many :queue_tasks

  before_validation :set_assistor_location_id, on: :create

  validates :requestor, presence: true
  validates :assistor_location_id, presence: true

  before_create :set_cohort
  before_create :set_day
  before_create :limit_one_per_user
  before_create :set_start_at

  # bc codereviews and direct assistances create requests (?!)
  # this is the least intrusive solution for now, until we get rid of that logic (if ever) - KV
  scope :genuine, -> { where.not(reason: "Offline assistance requested").where(type: nil) }
  scope :open_requests, -> { where(canceled_at: nil).where(assistance_id: nil) }
  scope :closed, -> {
    genuine
      .where(canceled_at: nil)
      .where.not(assistance_id: nil)
      .includes(:assistance)
      .references(:assistance)
      .where.not(assistances: { end_at: nil })
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
  scope :requestor_cohort_in_locations, ->(locations) {
    if locations.is_a?(Array) && !locations.empty?
      includes(requestor: { cohort: :location })
        .where(locations: { name: locations })
        .references(:requestor, :cohort, :location)
    end
  }
  scope :for_cohort, ->(cohort) { where(cohort_id: cohort) if cohort }
  scope :for_location, ->(location) { where(assistor_location_id: location) }
  scope :oldest_requests_first, -> { order(start_at: :asc) }
  scope :newest_requests_first, -> { order(start_at: :desc) }
  scope :requested_by, ->(user) { where(requestor: user) }
  scope :code_reviews, -> { where(type: 'CodeReviewRequest') }
  scope :between_dates, ->(start_date, end_date) { where(start_at: start_date..end_date) }
  scope :for_cohort, ->(cohort) { where(cohort_id: cohort) }
  scope :for_program, ->(program) { joins(:cohort).where(cohorts: { program_id: program }) }

  scope :wait_times_between, ->(low, high) {
    where('(EXTRACT(EPOCH FROM (assistances.start_at - assistance_requests.start_at)) / 60.0)::float BETWEEN ? AND ?', low, high)
  }

  def cancel
    self.canceled_at = Time.current
    save
  end

  def start_assistance(assistor)
    return false if assistor.blank? || assistance.present?

    if cohort.program.has_assistance_hangouts?
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
    self.class.open_requests.where(type: nil).for_location(assistor_location).where('assistance_requests.id < ?', id).count + 1 if open?
  end

  # this offline assistance request record thing is annoying and silly, but bigger code debt to fix/remove at a later time - KV
  def offline?
    reason == 'Offline assistance requested'
  end

  private

  def set_cohort
    self.cohort_id = requestor.try :cohort_id
  end

  def set_day
    self.day = CurriculumDay.new(Time.current, cohort).to_s if cohort
  end

  def set_start_at
    self.start_at ||= Time.current
  end

  def limit_one_per_user
    if type.nil? && !offline? && requestor.assistance_requests.where(type: nil).open_or_in_progress_requests.exists?
      errors.add :base, 'Limit one open/in progress request per user'
      false
    end
  end

  def set_assistor_location_id
    if requestor
      self.assistor_location_id = requestor.cohort.local_assistance_queue? ?
        requestor.location_id :
        requestor.cohort.location_id
    end
  end

end
