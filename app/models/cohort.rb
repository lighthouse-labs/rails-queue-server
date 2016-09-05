class Cohort < ApplicationRecord

  belongs_to :program
  belongs_to :location

  has_many :students
  has_many :recordings
  has_many :tech_interviews

  validates :name, presence: true
  validates :start_date, presence: true
  validates :program, presence: true
  validates :location, presence: true

  validates :code,  uniqueness: true,
                    presence: true,
                    format: { with: /\A[-a-z]+\z/, allow_blank: true },
                    length: { minimum: 3, allow_blank: true }

  scope :upcoming, -> { where('cohorts.start_date > ?', Date.current) }
  scope :chronological, -> { order(start_date: :asc) }
  scope :most_recent, -> { order(start_date: :desc) }
  scope :starts_between, -> (from, to) { where("cohorts.start_date >= ? AND cohorts.start_date <= ?", from, to) }
  scope :is_active, -> { starts_between(Date.current - 8.weeks, Date.current) }

  # assumes monday start date =/ - KV
  def end_date
    start_date.advance(weeks: WEEKS, days: 4)
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

  def week
    CurriculumDay.new(Date.current, self).week
  end

end
