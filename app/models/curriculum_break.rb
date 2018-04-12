class CurriculumBreak < ApplicationRecord

  # Created to support Holiday Break for cohorts that go over the Holidays. The
  # break is restricted to be by the week to preserve the scheduling of day activities.
  # Eg. day 3 always being a webdnesday. At this time only 1 break per cohort is
  # supported, and the starts_on must be a monday. The class relies heavily on
  # the index of days from the start of the cohort.

  belongs_to :cohort

  validates :reason, :starts_on, :num_weeks, presence: true
  validate :starts_on_monday
  validate :within_timeframe

  def starts_on_day_number
    (starts_on - cohort.start_date).to_i
  end

  def active_on_day_number?(day_num)
    day_number_range.include?(day_num)
  end

  def right_before_break_week_number
    # any valid CurriculumDay for this cohort will work, as we just want access this method
    cd = CurriculumDay.new("w01d1", cohort)
    cd.determine_week_without_breaks(day_number_before_break)
  end

  private

  def starts_on_monday
    errors.add(:starts_on, "breaks need to start on a monday") unless starts_on.monday?
  end

  def within_timeframe
    cohort_range = cohort.start_date..(cohort.start_date + cohort.program.weeks.weeks)
    errors.add(:starts_on, "needs to be during the cohort") unless cohort_range.cover?(starts_on)
  end

  def day_number_range
    starts_on_day_number..ends_on_day_number
  end

  def day_number_before_break
    starts_on_day_number - 1
  end

  def ends_on_day_number
    (starts_on_day_number + (7 * num_weeks) - 1).to_i
  end

end
