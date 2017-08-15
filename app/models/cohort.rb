class Cohort < ApplicationRecord

  belongs_to :program
  belongs_to :location

  has_many :students
  has_many :rolled_out_students, foreign_key: 'initial_cohort_id', class_name: 'Student'
  has_many :recordings
  has_many :tech_interviews

  validates :name, presence: true
  validates :start_date, presence: true
  validates :program, presence: true
  validates :location, presence: true

  validates :code,  uniqueness: true,
                    presence:   true,
                    format:     { with: /\A[0-9a-zA-Z]+\z/, allow_blank: true },
                    length:     { minimum: 3, allow_blank: true }

  scope :upcoming, -> { where('cohorts.start_date > ?', Date.current) }
  scope :chronological, -> { order(start_date: :asc) }
  scope :most_recent_first, -> { order(start_date: :desc) }
  scope :starts_between, ->(from, to) { where("cohorts.start_date >= ? AND cohorts.start_date <= ?", from, to) }
  scope :is_active, -> { starts_between(Date.current - 8.weeks, Date.current) }
  scope :active_or_upcoming, -> { upcoming.or(Cohort.is_active) }

  # assumes monday start date =/ - KV
  def end_date
    start_date.advance(weeks: program.weeks, days: 4)
  end

  def upcoming?
    start_date > Date.current
  end

  def active?
    start_date >= (Date.current - 8.weeks) && start_date <= Date.current
  end

  def finished?
    start_date < (Date.current - 8.weeks)
  end

  delegate :week, to: :curriculum_day

  def name_with_location
    "#{name} - #{location.try(:name) || 'No Location'}"
  end

  def curriculum_day(date = nil)
    date ||= Date.current
    CurriculumDay.new(date, self)
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

end
