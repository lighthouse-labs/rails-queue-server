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

    @date = @date.to_s if @date.is_a?(CurriculumDay)

    if @date.is_a?(String) && @cohort && @date != 'setup'
      @date = calculate_date
    end
  end

  def to_s
    return @to_s if @to_s

    w = determine_w
    @to_s = if day_number <= 0
      # day_number may be negative if cohort hasn't yet started
      "w1d1"
    elsif w > program.weeks
      "w#{program.weeks}e"
    elsif @date.sunday? || @date.saturday?
      "w#{w}e"
    else
      d = determine_d
      "w#{w}d#{d}"
    end
  end

  def week
    determine_w
  end

  def <=>(other)
    if !other.is_a?(CurriculumDay)
      # assume it's a "w2d4" sort of thing
      other = CurriculumDay.new(other, @cohort)
    end
    self.date <=> other.date
  end

  def unlocked_until_day
    if program.curriculum_unlocking == 'weekly'
      date = Date.current.sunday
      CurriculumDay.new(date, @cohort)
    else
      self
    end
  end

  def unlocked?
    # return true if @date == 'setup'
    # return true if unlock_weekend_on_friday
    return false unless @cohort
    return false if @cohort.start_date > Date.current
    if program.curriculum_unlocking == 'weekly'
      self.date.cweek <= today.date.cweek || self.date.year < today.date.year
      # 53rd week can roll over into the new year, preventing access from remaining days of that week.
      # if Jan 1st is a thursday, it will prevent access until the week ends.
    else # assume daily
      self.date <= today.date
    end
  end

  def today?
    self.to_s == today.to_s
  end

  def info
    DayInfo.where(day: self.to_s).first
  end

  def day_number
    (@date.to_date - @cohort.start_date).to_i
  end

  private

  def today
    @today ||= CurriculumDay.new(Date.current, @cohort)
  end

  def friday?
    self.to_s.ends_with?('5')
  end

  def weekend?
    self.to_s.ends_with?('e')
  end

  def unlock_weekend_on_friday
    (friday? && weekend?) && (self.to_s[1] == today.to_s[1])
  end

  def determine_w
    d = day_number
    if day_number <= 0
      1
    else
      w = (day_number / 7) + 1
      w > program.weeks ? program.weeks : w
    end
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
    wday = (weekdays.reverse.detect {|d| d.to_i <= wday } || weekdays.first)
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
    week, dow = date_parts[1].to_i, date_parts.last
    dow = dow == 'e' ? 6 : dow.to_i # weekend is day 6 (saturday)

    # limitation: assume start date is always a monday
    # for monday dow = 1 so advance by 0 (no advance) if dow = 1. Hence the -1 offset on dow
    date = @cohort.start_date.monday.advance(weeks: week - 1)
    if days_per_week == 5
      date = date.advance(days: dow - 1)
    else
      # dow of 2 (d2) may be Tuesday ... but could also be Thursday if we don't have 5 day weeks
      # This would happen if weekdays = [2, 4]
      # In the example above, d1 = Tuesday, d2 = Thursday
      d = weekdays[dow - 1].to_i
      date = date.advance(days: d - 1)
    end
    date
  end

end
