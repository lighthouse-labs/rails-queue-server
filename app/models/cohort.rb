class Cohort < ApplicationRecord

  belongs_to :program
  belongs_to :location

  has_many :students
  has_many :rolled_out_students, foreign_key: 'initial_cohort_id', class_name: 'Student'
  has_many :recordings
  has_many :tech_interviews
  # only supports one break per cohort
  has_one :curriculum_break

  validates :name, presence: true
  validates :start_date, presence: true
  validates :program, presence: true
  validates :location, presence: true
  validate  :disable_queue_days_are_valid

  validates :code,  uniqueness: true,
                    presence:   true,
                    format:     { with: /\A[-a-z]+\z/, allow_blank: true },
                    length:     { minimum: 3, allow_blank: true }

  include PgSearch
  include DisableQueueDayValidators

  pg_search_scope :by_keywords,
                  associated_against: {
                    students: [:first_name, :last_name, :email, :phone_number, :github_username]
                  },
                  using:              {
                    tsearch: {
                      dictionary: "english",
                      any_word:   true,
                      prefix:     true
                    }
                  }

  scope :upcoming, -> { where('cohorts.start_date > ?', Date.current) }
  scope :chronological, -> { order(start_date: :asc) }
  scope :most_recent_first, -> { order(start_date: :desc) }
  scope :starts_between, ->(from, to) { where("cohorts.start_date >= ? AND cohorts.start_date <= ?", from, to) }
  scope :is_active, -> { starts_between(Date.current - Program.first.weeks.weeks, Date.current) }
  scope :active_or_upcoming, -> { upcoming.or(Cohort.is_active) }
  scope :is_finished, -> { where('cohorts.start_date < ?', (Date.current - Program.first.weeks.weeks)) }
  scope :started_before, ->(date) { where('cohorts.start_date <= ?', date) }
  scope :started_after, ->(date) { where('cohorts.start_date >= ?', date) }
  scope :running_in_location, ->(location) {
    where(location_id: location.supported_by_location ? location.supported_by_location : location)
  }
  # assumes monday start date =/ - KV
  # last day of instruction, friday of the last week - JM
  def end_date
    advance_weeks = curriculum_break ? (program.weeks - 1) + curriculum_break.num_weeks : program.weeks - 1
    start_date.advance(weeks: advance_weeks, days: 4)
  end

  def upcoming?
    start_date > Date.current
  end

  def started?
    start_date <= Date.current
  end

  def active?
    Date.current >= start_date && Date.current <= end_date
  end

  def finished?
    Date.current > end_date
  end

  delegate :week, to: :curriculum_day

  def name_with_location
    "#{name} - #{location.try(:name) || 'No Location'}"
  end

  def curriculum_day(date = nil)
    date ||= Date.current
    CurriculumDay.new(date, self)
  end

  def on_curriculum_day?(curriculum_day)
    curriculum_day == CurriculumDay.new(Date.current, self).to_s
  end

  def student_locations
    Location.where(id: students.active.pluck('distinct location_id'))
  end

  def num_students_started
    students.count + rolled_out_students.count
  end

  def num_remote_students_started
    students.remote.count + rolled_out_students.count
  end

  def active_queue?
    program.has_queue? && active? && !disable_queue_days.include?(curriculum_day.to_s)
  end

end
