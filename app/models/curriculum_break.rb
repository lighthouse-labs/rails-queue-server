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

  def day_number_starts_on
    (starts_on - cohort.start_date).to_i
  end

  def day_number_ends_on
    (day_number_starts_on + (7 * num_weeks) - 1).to_i
  end

  def day_number_range
    day_number_starts_on..day_number_ends_on
  end

  def day_number_before_break
    day_number_starts_on - 1
  end

  def active_on_day_number?(day_num)
    day_number_range.include?(day_num)
  end

  def week_number_before_break
    # any valid CurriculumDay for this cohort will work, as we just want access to a private method
    cd = CurriculumDay.new("w1d1", cohort)
    cd.send(:determine_week_without_breaks, day_number_before_break)
  end

end
