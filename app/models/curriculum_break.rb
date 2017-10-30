class CurriculumBreak < ApplicationRecord

  belongs_to :cohort
  validates :reason, :starts_on, :num_weeks, presence: true
  validate :starts_on_monday
  validate :within_timeframe

  def starts_on_monday
    errors.add(:starts_on, "breaks need to start on a monday") unless starts_on.monday?
  end

  def within_timeframe
    cohort_range = cohort.start_date..(cohort.start_date + cohort.program.weeks.weeks)
    errors.add(:starts_on, "needs to be during the cohort") unless cohort_range.cover?(starts_on)
  end

end
