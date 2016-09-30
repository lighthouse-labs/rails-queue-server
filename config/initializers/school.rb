WEEKS                = (ENV['WEEKS'] || 8).to_i
WEEKENDS             = ENV['WEEKENDS'] ? ENV['WEEKENDS'] == 'true' : false
CURRICULUM_UNLOCKING = ENV['CURRICULUM_UNLOCKING'] || 'daily'

DAY_FEEDBACK_AFTER   = (ENV['DAY_FEEDBACK_AFTER'] || 64_800).to_i # seconds since beginning of day

DAY_REGEX = /\A(w\dd\d)|(w\de)|(setup)|(prep\d)\z/