# Not an ActiveRecord model

class CurriculumDay

  attr_reader :date
  attr_reader :raw_date
  attr_reader :cohort
  attr_reader :program

  include Comparable

  def initialize(date, cohort)
    @raw_date = date
    @date = date
    @cohort = cohort
    @program = cohort.try :program
    @curriculum_break = cohort.curriculum_break if cohort

    @date = @date.to_s if @date.is_a?(CurriculumDay)
    calculate_date if @date.is_a?(String) && @cohort
  end

  def to_s
    return @to_s if @to_s
    w = determine_w

    # prefix with 0 if needs to be double digit and isn't
    week = double_digit_week? && w < 10 ? "0#{w}" : w

    @to_s = if on_break?(day_number)
              "w#{week}e"
            elsif day_number <= 0
              # day_number may be negative if cohort hasn't yet started
              "w#{'0' if double_digit_week?}1d1"
            elsif w > program.weeks
              "w#{program.weeks}e"
            elsif @date.sunday? || @date.saturday?
              "w#{week}e"
            else
              d = determine_d
              "w#{week}d#{d}"
            end
  end

  def double_digit_week?
    program.weeks >= 10
  end

  def week
    determine_w
  end

  def <=>(other)
    unless other.is_a?(CurriculumDay)
      # assume it's a "w2d4" sort of thing
      other = CurriculumDay.new(other, @cohort)
    end
    date <=> other.date
  end

  def unlocked_until_day(timezone)
    if program.curriculum_unlocking == 'weekly'
      unlocked_date = sunday_night?(timezone) ? date.sunday + 6.days : date.sunday
      CurriculumDay.new(unlocked_date, @cohort)
    else
      self
    end
  end

  def unlocked?(timezone)
    # return true if @date == 'setup'
    # return true if unlock_weekend_on_friday
    return false unless @cohort
    return false if @cohort.start_date > Date.current
    if program.curriculum_unlocking == 'weekly'
      # Allowing access on Sunday night as well.
      next_weekend = CurriculumDay.new(DateTime.now.sunday + 6.days, @cohort)
      unlocked_based_on_current_week? || unlocked_based_on_year? || unlocked_based_on_sunday_night?(timezone, next_weekend)
    else # assume daily
      date <= today.date
    end
  end

  def unlocked_based_on_current_week?
    correctCweek(date) <= correctCweek(today.date) && date.year <= today.date.year
  end

  def unlocked_based_on_year?
    date.year < today.date.year
  end

  def unlocked_based_on_sunday_night?(timezone, next_weekend)
    (sunday_night?(timezone) && (self <=> next_weekend).to_i < 1)
  end

  def today?
    to_s == today.to_s
  end

  def info
    DayInfo.find_by(day: to_s)
  end

  def day_number
    (@date.to_date - @cohort.start_date).to_i
  end

  def prev_day
    CurriculumDay.new(@date.to_date.prev_day, @cohort)
  end

  def start_of_week
    CurriculumDay.new(@date.to_date.monday, @cohort)
  end

  def end_of_week
    CurriculumDay.new(@date.to_date.sunday, @cohort)
  end

  def determine_week_without_breaks(day_num)
    # has to be public, calling it from CurriculumBreak, ya i know, this is not ideal
    w = (day_num / 7) + 1
    w > program.weeks ? program.weeks + 1 : w.to_i
  end

  private

  def today
    @today ||= CurriculumDay.new(Date.current, @cohort)
  end

  def friday?
    to_s.ends_with?('5')
  end

  def weekend?
    to_s.ends_with?('e')
  end

  def unlock_weekend_on_friday
    (friday? && weekend?) && (to_s[1] == today.to_s[1])
  end

  def determine_d
    return @date.wday if days_per_week == 5
    # "d1" would normally be monday, right?
    # Well now it could also be tuesday
    # Eg Given `weekdays = [2, 4]` (tuesdays and thursdays)
    # then d1 = tuesday, d2 = thursday
    wday = @date.wday # 1,2,3,4 or 5 (eg: 3 for 'wednesday')
    # 1 (mon) - 1,3 => 1
    # 2 (tue) - 1,3 => 1
    # 3 (wed) - 1,3 => 3
    # 4 (thu) - 1,3 => 3
    # 5 (fri) - 1,3 => 3
    # 6 (sat) - 1,3 => 3
    # 7 (sun) - 1,3 => 3
    wday = (weekdays.reverse.detect { |d| d.to_i <= wday } || weekdays.first)
    weekdays.index(wday) + 1
  end

  def days_per_week
    program.try(:days_per_week) || 5
  end

  # Array format of active wday values: 1,2,3,4,5 (represents: M,T,W,TH,F)
  def weekdays
    cohort.weekdays.to_s.split(',')
  end

  def calculate_date
    date_parts = @date.match(/w(\d+)((d(\d))|e)/).to_a.compact # eg: w5d1 or w4e

    # dow = day of week
    week = date_parts[1].to_i
    dow = date_parts.last
    dow = dow == 'e' ? 6 : dow.to_i # weekend is day 6 (saturday)

    # limitation: assume start date is always a monday
    # for monday dow = 1 so advance by 0 (no advance) if dow = 1. Hence the -1 offset on dow
    date = @cohort.start_date.monday.advance(weeks: week - 1)
    if days_per_week == 5
      date = date.advance(days: dow - 1)
    else
      if dow == 6
        # It's a weekend.
        # Need to advance (from Monday) by 5 days (ie dow - 1) to get to Saturday.
        date = date.advance(days: 5)
      else
        # It's not a weekend AND this is not a 5d program. We have to do something a bit more clever
        # dow of 2 (d2) may be Tuesday ... but could also be Thursday if we don't have 5 day weeks
        # This would happen if weekdays = [2, 4]
        # In the example above, d1 = Tuesday, d2 = Thursday
        d = weekdays[dow - 1].to_i
        date = date.advance(days: d - 1)
      end
    end

    @date = date # date needs to be set for day_number to be correct
    @date = date.advance(weeks: @curriculum_break.num_weeks) if adjust_date_calculation_for_break?(day_number)
  end

  def determine_w
    d = day_number
    if d <= 0
      1
    elsif @curriculum_break
      determine_week_with_breaks(d)
    else
      determine_week_without_breaks(d)
    end
  end

  def determine_week_with_breaks(day_num)
    w = (day_num / 7) + 1
    if on_break?(day_num)
      @curriculum_break.right_before_break_week_number
    elsif past_end_week_of_cohort?(w)
      program.weeks + 1
    elsif post_break_yet_active_week_number?(w)
      w - @curriculum_break.num_weeks
    else
      w
    end
  end

  def on_break?(day_number)
    @curriculum_break&.active_on_day_number?(day_number)
  end

  def past_end_week_of_cohort?(week_number)
    week_number > (program.weeks + @curriculum_break.num_weeks)
  end

  def post_break_yet_active_week_number?(week_number)
    return false if past_end_week_of_cohort?(week_number)
    week_number > (@curriculum_break.right_before_break_week_number + @curriculum_break.num_weeks)
  end

  def adjust_date_calculation_for_break?(day_number)
    # adjust if there is a break and the date calculation starts on or if after
    # the start of the break by day number. EG: CurriculumDay('w2d1', some_cohort)
    # and for some_cohort a Break starts on week 2, the date returned should be
    # adjusted for the break
    @curriculum_break && (day_number >= @curriculum_break.starts_on_day_number)
  end

  def sunday_night?(timezone)
    user_timezone_offset = ActiveSupport::TimeZone[timezone].formatted_offset
    user_current_time = Time.now.getlocal(user_timezone_offset)
    day_of_week = user_current_time.strftime("%A")
    hour = user_current_time.strftime("%H").to_i
    ## Sunday after 8PM, users local time
    day_of_week == 'Sunday' && hour >= 20
  end

  def correctCweek(date)
    week = date.cweek
    #Last week of december is incorrectly identified as 1st week
    if week == 1 && date.month == 12
      week = 52
    #First week of January is incorrectly identified as 52nd week
    elsif week > 52 && date.month == 1
      week = 1
    end
    week
  end

end
