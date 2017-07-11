Date::DATE_FORMATS[:friendly] = ->(date) { date.strftime("%B #{date.day.ordinalize} %Y") }
Date::DATE_FORMATS[:short_friendly] = ->(date) { date.strftime("%b #{date.day}") }

Time::DATE_FORMATS[:friendly] = ->(date) { date.strftime("%B #{date.day.ordinalize} %Y") }

Time::DATE_FORMATS[:date_and_time] = ->(date) { date.strftime("%B #{date.day.ordinalize} %Y %H:%M") }
Time::DATE_FORMATS[:short_friendly] = ->(date) { date.strftime("%b #{date.day}") }
