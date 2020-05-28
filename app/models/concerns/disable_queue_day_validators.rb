module DisableQueueDayValidators

  private

  def disable_queue_days_are_valid
    days_are_formatted_correctly
    days_are_in_the_correct_range
  end

  def days_are_formatted_correctly
    if disable_queue_days.any?
      disable_queue_days.each do |day|
        errors.add(:disable_queue_days, "has one or more days not formatted correctly") unless day.match?(DAY_REGEX)
      end
    end
  end

  def days_are_in_the_correct_range
    if disable_queue_days.any?
      week_num_regex = /\d+(?=d|e)/
      disable_queue_days.each do |day|
        match_data = week_num_regex.match(day)
        return false if match_data.nil?

        week_num = week_num_regex.match(day)[0].to_i
        in_range = (1..Program.first.weeks).member?(week_num)
        errors.add(:disable_queue_days, "has a entry with a invaild week number, not in the program range") unless in_range
      end
    end
  end

end
