Date::DATE_FORMATS[:friendly] = ->(date) { date.strftime("%B #{date.day.ordinalize} %Y") }
Date::DATE_FORMATS[:short_friendly] = ->(date) { date.strftime("%b #{date.day}") }

Time::DATE_FORMATS[:friendly] = ->(date) { date.strftime("%B #{date.day.ordinalize} %Y") }

Time::DATE_FORMATS[:date_and_time] = ->(date) { date.strftime("%B #{date.day.ordinalize} %Y %H:%M") }
Time::DATE_FORMATS[:short_friendly] = ->(date) { date.strftime("%b #{date.day}") }

Date::DATE_FORMATS[:quarter] = Time::DATE_FORMATS[:quarter] = ->(date) {
  case [date.day, date.month]
  when [1, 1]
    date.strftime("Q1 %Y")
  when [1, 4]
    date.strftime("Q2 %Y")
  when [1, 7]
    date.strftime("Q3 %Y")
  when [1, 10]
    date.strftime("Q4 %Y")
  else
    date.strftime("Q? %Y")
  end
}
